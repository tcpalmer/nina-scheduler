---
layout: default
title: Synchronization
nav_order: 100
has_children: false
---

# Synchronization

The existing NINA Synchronization plugin provides support for multiple OTAs/cameras on a single mount with a single guider.  It does this by setting up communications between two or more running instances of NINA and then synchronizing some activities via custom instructions in each sequence.  The main use case is to have a primary NINA instance handle mount operations and guiding and then synchronize with secondary instances so they can take exposures when the primary is but then wait while the primary is doing mount or dithering operations.

By controlling target selection and exposure planning, Target Scheduler (TS) precludes using the existing instructions implemented by the Synchronization plugin.  There are several challenges:
1. In TS, projects and targets explicitly belong to one NINA profile.  Since you can only run multiple instances of NINA if each is running a different profile, each instance would see a different set of active projects and targets.
2. Given #1, the primary will have to send exposure details to each secondary.
3. Also given #1, each secondary will have to send acquisition metadata back to the primary so it could do image grading (if enabled) and update the database.

### Synchronization Communications

[Grpc](https://grpc.io/) will be used for low-level interprocess (NINA to NINA) communications.  This is the same RPC framework used by the existing Synchronization plugin and will be modeled loosely on that approach (at least at a low level).

Grpc is a RPC client/server (not peer-to-peer) protocol: clients can make requests to the server but not vice-versa.  For this reason, clients will have to poll the server when waiting for instructions.  If the server has something for the client to do, it can return instructions in the response.  Otherwise, the client would continue waiting/polling.

In the TS implementation (as in the Synchronization plugin), one NINA instance will be the server, known as the _primary_ instance.  This instance will be running the mount and the guider.  In TS, the first NINA instance to start will automatically be selected as the primary.  Any additional NINA instances started will automatically become _secondary_ instances and will register themselves as clients with the primary.  'Starting' in this context just means starting NINA, not starting a sequence.

Secondaries will have a background 'keepalive' thread that periodically calls the primary so that the primary knows it is still active and what state it is in.

This implementation will use Windows Named Pipes as the underlying communications mechanism.

## Assumptions
Proper operation of synchronization for TS will assume the following:
* The primary goal of multiple OTAs/cameras on a single mount is to 'gang up' on the desired exposures for your targets and complete them faster.
* All NINA instances are running on the same Windows computer.
* Each NINA instance will be using a different NINA profile designed to support synchronization.
* The TS projects and targets you wish to image will be defined under the profile used by the primary instance.
* The capabilities of the equipment used by each setup (primary and all secondaries) are roughly equivalent.  This is most important for filter wheels (including filter naming) and somewhat less so for camera capabilities and focal lengths.
* Camera exposure settings such as gain, offset, binning, and readout mode could vary across the cameras used by leveraging the way Exposure Templates work for different profiles (see below).
* Filter offsets are used in all profiles so that refocusing after a filter change isn't necessary.
* The primary instance should manage all safety related activities (e.g. park on unsafe, close roof, etc).
* The sequences used on all NINA instances will be customized to support synchronization.
* The sequences used for each secondary instance should closely approximate the primary, with the following exceptions:
  * No mount or guider connect/disconnect
  * No instructions or triggers involving the mount, e.g. Slew, Park/Unpark, Meridian Flip or Center after Drift.
  * No instructions or triggers involving the guider, e.g. Dither.
  * Autofocus - see below.
* The TS projects/targets should handle dithering themselves and not rely on a Dither After Exposures trigger in the sequence.
* In some cases (TBD), it would be necessary to disable image grading across all instances participating in synchronized operations.

## Autofocus

Supporting synchronization while allowing triggered autofocusing is potentially problematic.  Any of the AF triggers like HFR Increase, Temperature Change, etc could potentially execute on a secondary at times that prevent clean synchronization with the primary.

In the normal flow, if a secondary is running a lengthy trigger operation after an exposure then it may not be back in the appropriate 'exposure wait' state when the primary is ready to send it another exposure.  The simplest solution is to skip that secondary for that exposure.  Presumably, the AF will complete before the next exposure and the secondary can join up then.

## Image Grading

Image Grading of images taken by secondaries is challenging:
* There is no guider attached to the secondaries so no RMS error value is available.
* Other grading metrics used like star count and HFR may not apply across images taken by the different cameras used - so you can't use all previous 'like' images for the statistical comparisons.

For these reasons, secondaries will send exposure metadata back to the primary for grading and database updates.  The following changes will also be necessary:
* The NINA profile ID of the instance used to take exposures will be added to the metadata so we can distinguish exposures taken by secondaries.
* During grading, we may be able to use the RMS error value that applied for the corresponding image taken by the primary.  However, if the start times of those images differed significantly, then the primary RMS error may not be usable.
* For star count and HFR, we will have to restrict the comparison images to only those taken with the same camera (by checking the profile IDs).

## Dithering

In contrast to autofocus and image grading, supporting dithering in TS synchronization happens naturally.  Since the primary will be handling dithering during normal TS operations, the secondaries will naturally be in 'exposure wait' state and therefore doing nothing while the primary dithers.

## Changes

### New Profile Preferences
The TS Profile Preferences panel will add a new property to the 'General Preferences' section:
  * _Enable for Synchronization_, default false.

NINA instances will only begin synchronization operations if _Enable for Synchronization_ is true in the profile settings used by that instance.

### Exposure Templates

If secondary instances use different cameras from the primary, you can handle some potential differences by using matching Exposure Templates in the profiles used for the secondaries.  For example:
* In the profile for the primary instance, you have Exposure Templates for L, R, G, and B that specify gain, offset, binning, and readout mode specific to the primary camera.
* In the profile for secondary 1, you create matching L, R, G, and B Exposure Templates but with different settings specific to the secondary 1 camera.  The exposure duration could also be different (ideally less than the primary) but that potentially wastes time on subsequent syncing.
* When secondary 1 receives a message to take an exposure, it will include the applicable Exposure Template name.  The secondary will look up that Exposure Template under its profile and use the one that matches the name.

If the cameras on the secondaries are identical to the primary, then you wouldn't need to do this and the secondary would fall back to using the matching Exposure Template under the primary's profile.

### New Instruction: Target Scheduler Synced Wait

This instruction is inserted into each sequence (perhaps more than once) prior to the TS Containers.  The sequences used by primary and secondary instances must have 'matching' Target Scheduler Synced Wait instructions.  When executed, it works as follows:
* If running on a secondary instance, it begins polling, telling the primary that it is in 'sync wait' state.
* If running on the primary instance, when it receives a 'sync wait' request from a secondary, it marks that instance as waiting.

On the server, if there are secondaries that have not yet reported to be 'sync wait', it returns a 'continue waiting' response to the secondary.  When all secondaries have reported 'sync wait', the server then responds (on the next request) with a 'proceed' response.  When the secondaries receive that, they end the Target Scheduler Sync Wait instruction and the secondary sequence proceeds with the next instruction.  The server instance proceeds when all secondaries have checked in and been told to continue.

There is certainly the potential for deadlock here:
* If a secondary was shutdown, then it's keepalive would stop which can be detected.  The primary simply wouldn't wait for a secondary with a stale keepalive time.
* If a secondary doesn't have a matching Target Scheduler Synced Wait instruction, then the primary will never move past the Sync Wait on its side.  Assuming all secondary keepalives are active, the primary will need an overall timeout on this operation so that it could keep going.  This timeout would have to be lengthy (many minutes) so that a client could perform operations like autofocus.
* If the sequence for a secondary isn't running, it can't enter the 'sync wait' state.  If we can detect if the sequence is stopped, we could change the secondary state to reflect that which would propagate to the server with the next keepalive.

Secondaries that didn't participate in this wait may still recover but that requires testing.

### New Instruction: Target Scheduler Synced Container

The sequences for each secondary instance will use the new _Target Scheduler Synced Container_ instruction instead of the existing Target Scheduler Container.  This instruction will support taking exposures on secondary instances at the direction of the primary as well as waiting while the primary performs other operations.

This will work as follows.  The assumption is that the primary is running the regular _Target Scheduler Container_ instruction which has started execution.  Each secondary is running this new instruction which has also started execution.
* Each secondary will begin polling, telling the primary that it is now in 'exposure wait' state - waiting for an imaging instruction.
* The primary will be running the normal planning, target selection, slew/center, and imaging loop.  When it is about to take an exposure, it stops and waits for all secondaries to enter 'exposure wait' state.  After all secondaries have entered this state, when each secondary subsequently checks in, the primary responds with the exposure instruction details and the secondary begins the exposure.  (Might need for secondary to call again immediately if it has accepted the exposure, in case some problem occurred.)
* The primary also begins the exposure.  When complete, it again stops and waits for all secondaries to report exposure completion (or error or stopped).
* When each secondary completes its exposure, it calls the primary and sends the exposure metadata details (or error).  The server performs image grading (if enabled) and records the exposure in the database.
* When all secondaries that were given the exposure have reported in that they are done, the primary continues with the next planned exposure.

This process will need deadlock timeouts too - in case a secondary that received an exposure instruction doesn't report in.

### Other Work
* Design primary/secondary communications, JSON objects, etc
* Implement primary/secondary connections and communications
* Startup/Teardown: start sync service if enabled in profile, unregister, disconnect in Teardown
* Need to add something to Acquired Images record to indicate whether the image was taken by primary or a secondary?
* Changing Enable for Synchronization might require a restart.
* We might need a custom strategy for Target Scheduler Synced Container so that triggers only execute after an exposure instruction.  This would prevent secondaries from dealing with triggers after (for example) a Switch Filter or Camera Readout mode instruction.
* TS logging around primary/secondary states, messaging, etc needs to be comprehensive.

### Secondary States
Once the Target Scheduler Synced Container begins execution, it will be in one of the following states:
* STARTUP: registering with primary
* ACTIVE: running but not waiting
* SYNC_WAIT: in the Target Scheduler Sync Wait instruction and waiting to proceed
* EXPOSURE_WAIT: in the Target Scheduler Synced Container instruction and waiting for the next exposure
* EXPOSING: actively taking an exposure
* ENDING: received end message, ending execution

Other potential states - assuming we can detect:
* SEQ_STOPPED: sequence is not running
* TRIGGER_RUNNING: a trigger is running (e.g. AF after exposure)

The primary will maintain the current state of each secondary.  In addition to the above states, a secondary could also be in an indeterminate state if:
* It has not yet started the Target Scheduler Synced Container
* The Target Scheduler Synced Container encounters an error or interrupt
* If the Target Scheduler Synced Container has ended

### Communications Protocol
Initial thoughts on primary/secondary communications protocol.

* Register secondary.  Secondary identification includes a guid (used to uniquely identify the secondary in all subsequent calls) and other information (TBD but could include profile ID, PID, secondary identifier).  Response includes the PID and profile ID of the primary.
* Unregister secondary
* Keepalive: inform the primary we are still active, includes the current state, so it can be maintained on the primary.
* SyncWait: inform primary we are in SYNC_WAIT state.  Response is either 'acknowledge' or 'continue'.
* ExposureWait: inform primary we are in EXPOSURE_WAIT state.  Response is either 'acknowledge', take exposure details, or 'complete' (end).
* ExposureAcknowledge: inform primary we have accepted the exposure and are starting it
* ExposureResults: inform primary of exposure results.  Could be image metadata or some error.

#### Instance Data
Each instance maintains the following:
* If the primary, a dictionary (keyed by guid) of the secondary details, including the latest state and keepalive time.
* If a secondary, the identifiers for the master plus current state.

