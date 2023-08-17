---
layout: default
title: Synchronization
nav_order: 1
has_children: false
---

# Synchronization

The existing NINA Synchronization plugin provides support for multiple OTAs/cameras on a single mount with a single guider.  It does this by setting up communications between two or more running instances of NINA and then synchronizing some activities.  The main use case is to have a primary NINA instance handle mount operations and guiding and then synchronize with secondary instances so they can take exposures when the primary is but then wait while the primary is doing mount or dithering operations.

By controlling target selection and exposure planning, Target Scheduler (TS) precludes using the existing instructions implemented by the Synchronization plugin.  There are several challenges:
1. In TS, projects and targets explicitly belong to one NINA profile.  Since you can only run multiple instances of NINA if each is running a different profile, each instance would see a different set of active projects and targets.
2. Given #1, the primary will have to send exposure details to each secondary.
3. Also given #1, each secondary will have to send acquisition metadata back to the primary so it could do image grading (if enabled) and update the database.

## Assumptions
Proper operation of synchronization for TS will assume the following:
* The primary goal of multiple OTAs/cameras on a single mount is to 'gang up' on the desired exposures for your targets and complete them faster.
* All NINA instances are running on the same Windows computer.
* Each NINA instance will be using a different NINA profile designed to support synchronization.
* The capabilities of the equipment used by each setup (primary and all secondaries) are roughly equivalent.  This is most important for filter wheels (including filter naming) and somewhat less so for camera capabilities and focal lengths.
* Camera exposure settings such as gain, offset, binning, and readout mode could vary across the cameras used by leveraging some enhancements to Exposure Templates (see below).
* The primary instance should manage all safety related activities (e.g. park on unsafe, close roof, etc).
* The sequences used on all NINA instances will be customized to support synchronization.
* The sequences used for each secondary instance should closely approximate the primary, with the following exceptions:
  * No mount or guider connect/disconnect
  * No instructions or triggers involving the mount, e.g. Slew, Park/Unpark, Meridian Flip or Center after Drift.
  * No instructions or triggers involving the guider, e.g. Dither.
  * Autofocus ... TBD
* The TS projects/targets would handle dithering themselves and not rely on a Dither After Exposures trigger in the sequence.
* In some cases (TBD), it would be necessary to disable image grading across all instances participating in synchronized operations.

## Changes

### New Profile Preferences
The TS Profile Preferences panel will add a new section named 'Synchronization' with two new properties:
  * _Enable for Synchronization_, default false.  If true, _Instance Identifier_ is required.
  * _Instance Identifier_ the identifier for an instance.  Used to help identify the instances.  Will be a dropdown with 'Primary', 'Secondary 1', 'Secondary 2', 'Secondary 3'.

### Exposure Templates

If secondary instances use different cameras from the primary, you can handle some potential differences by using matching Exposure Templates in the profiles used for the secondaries.  For example:
* In the profile for the primary instance, you have Exposure Templates for L, R, G, and B that specify gain, offset, binning, and readout mode specific to the primary camera.
* In the profile for secondary 1, you create matching L, R, G, and B Exposure Templates but with different settings specific to the secondary 1 camera.  The exposure duration could also be different (ideally less than the primary) but that potentially wastes time on subsequent syncing.
* When secondary 1 receives a message to take an exposure, it will include the applicable Exposure Template name.  The secondary will look up that Exposure Template under its profile and use the one that matches the name.

If the cameras on the secondaries are identical to the primary, then you wouldn't need to do this and the secondary would fall back to using the matching Exposure Template under the primary's profile.

### New Instruction: Target Scheduler Sync Wait

This instruction is inserted into each sequence (maybe more than once) prior to the TS Containers.  It does the following:
* If primary/secondary communications have not been started, the primary starts listening for connections and the secondaries all register with the primary.
* Once all secondaries have registered, they each enter the WAIT state.
* The primary proceeds

BUT WHAT TELLS THE SECONDARIES THEY CAN PROCEED?  Needs more thinking ... will the following work?

Primary                  Secondary
slew to AF location
Sync Wait                Sync Wait
AF                       AF
Sync Wait                Sync Wait

Don't forget secondary camera cool down time

So that the primary (when it hits first TS Sync Wait) can have an idea of how many secondaries there are, it could look for other running NINA processes and get a count.  When each secondary registers, it sends its PID as part of the identifier.

### New Instruction: Target Scheduler Synced Container

The sequences for each secondary instance will use the new _Target Scheduler Synced Container_ instruction instead of the existing Target Scheduler Container.  This instruction will support taking exposures on secondary instances at the direction of the primary as well as waiting while the primary performs other operations.

### Other
* Design primary/secondary communications, JSON objects, etc
* Implement primary/secondary connections and communications.  Do we need heartbeat?
* New Target Scheduler Synced Container instruction
* Need to add something to Acquired Images record to indicate whether the image was taken by primary or a secondary?
* TS logging around primary/secondary states, messaging, etc needs to be comprehensive.

### Secondary States
Once the Target Scheduler Synced Container begins execution, it will be in one of the following states:
* STARTUP: registering with primary
* WAIT: ready and waiting for next action
* EXPOSING: actively taking an exposure
* ENDING: received end message, ending execution

The primary will maintain the current state of each secondary.  In addition to the above states, a secondary could also be in an indeterminate state if:
* It has not yet started the Target Scheduler Synced Container
* The Target Scheduler Synced Container encounters an error or interrupt
* If the Target Scheduler Synced Container has ended

### Communications Protocol
Initial thoughts on primary/secondary communications protocol.

#### Secondary to Primary
* Register instance: unique identifier and instance number (from profile preference).  The response back from the primary contains the profile ID of the primary and it's GUID. (STARTUP -> WAIT)
* Exposure complete: exposure details, metadata, etc (EXPOSING -> WAIT)
* Query response: secondary state (synchronous)

All messages from secondary to primary will include the unique identifier(s) for the secondary.  Probably GUID, _Instance Identifier_ from profile setting, and the NINA PID.

The existing Synchronization plugin also uses heartbeat messages, presumably to let the master learn of secondary issues ASAP.  TBD whether this will be needed here.

#### Primary to Secondary
* Query secondary state (synchronous)
* Take Exposure: exposure details (WAIT -> EXPOSING)
* Interrupt: interrupt if taking an exposure (* -> WAIT)
* End: end execution of secondary Target Scheduler Synced Container (* -> ENDING)

#### Instance Data
Each instance maintains the following:
* If the primary, a list of all secondaries, their identifiers (GUID, secondary number, and profile ID), and last known state.
* If a secondary, the identifiers for the master plus current state.
* Details of established named pipes.

## Execution

### Startup

* The NINA instances can be started in any order.
* The instance designated as primary is responsible for operating the mount and the guider (for guiding and dithering) and will use the existing TS Container instruction in its sequence.
* The secondary instances will use the new Target Scheduler Synced Container instruction.
* The sequences on each instance should be started.
* When the TS Container on the primary begins execution, it will stop and wait for secondaries to register themselves.  Since the secondaries will likely have already reached execution of the Target Scheduler Synced Container instruction first (having much less to do), they will have to wait and periodically retry to connect to the primary to register.
* Once the primary is (reasonably) sure that all secondaries have registered, it can begin planning, target selection, and imaging.

### Runtime

#### Normal Flow

* Each secondary instance will get to the Target Scheduler Synced Container execution which will initially wait for direction from the primary.
* The primary will execute the Target Scheduler Container instruction.  It will call the TS planner in a loop as usual:
  * If a wait is returned, the primary will wait as usual.  The secondaries are assumed to be waiting already.
  * If a target plan is returned, it will process the instructions in the plan.
  * For each slew/center instruction:
    * Ensure that all secondaries are in WAIT state.
    * The primary will perform the slew/center as usual.
  * For each exposure instruction:
    * Ensure that all secondaries are ready for an exposure (WAIT).
    * Start the exposure on the primary.
    * Send the exposure details to each secondary and receive acknowledgement that it was accepted.
    * Each secondary starts the same exposure (filter, exposure length, etc, etc)
    * When the exposure completes on the primary, it waits for each secondary to report that it is done.  There needs to be a timeout on this and handling to ensure we don't hang.  Might have to tell a secondary to cancel an exposure.
    * Each secondary that successfully completed the exposure returns details back to the primary.  This includes whatever is needed to create the acquired data record and (potentially) grade the image on the primary.  The primary may have to fill in some data from what it knows (e.g. guiding RMS during that image).
    * Each secondary returns to wait mode.
    * The primary then continues with the next instruction in the plan.
  * For each dither instruction:
    * Ensure that all secondaries are in WAIT state.
    * The primary will perform the dither as usual.

#### Interrupts

TBF

How can we handle interrupts from external events on the primary like triggers?  Can TS detect the interrupt and then interrupt the secondaries?  Note that most triggers would be after each instruction completes so we'd stay in sync.  But that's not true for those using watchdog threads which could interrupt any operation at any time.

* Autofocus
* MF
* CaD

#### Autofocus

In particular, how can the secondaries do proper autofocusing?  If we could detect that TS was interrupted by an AF, then we could tell the secondaries to interrupt and also do an AF - but would have to sync up.  Otherwise, we could mandate (by profile pref) that an AF is added before each new target (after slew/center).  We could then sync up on that operation.  And maybe mandate an AF on filter change?  Unless filter offsets are in use?

## Questions

* What happens when the primary instance sequence is stopped?
* What happens when the primary instance sequence is reset?

## To Be Figured Out

* Windows named pipes ...
* If more than one instance is started as primary, can we detect that?
* The primary isn't going to know how many secondaries will be active so has no way to determine when 'all' have registered other than waiting some 'reasonable' period of time.  Is there a better way to do startup and registration?
* Can we make secondaries have a read only connection to the database?
* How can Autofocus triggers on the primary work?  Can the primary TS Container detect when it was interrupted and inform secondaries?
* How can safety state/instructions operate for the secondaries?
* What happens when the primary TS stop triggers stops a plan?
* I don't think it's possible for grading to be done by the primary on behalf of the secondaries: since they could differ in terms of FL, filter specs, and camera capabilities, we can't compare a secondary instance against whatever recent images are saved on the primary side.  Perhaps users could disable grading unless they know that the capture capabilities of all instances will be very similar.  Possible to match a secondary image with the one taken by the primary at the same time?  If so, could use guiding metadata from that for grading.  Or at least record it even if not used for grading.


