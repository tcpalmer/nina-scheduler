---
layout: default
title: Synchronization
nav_order: 10
has_children: false
---

# Synchronization

The existing NINA Synchronization plugin provides support for multiple OTAs/cameras on a single mount with a single guider.  It does this by setting up communications between two or more running instances of NINA and then synchronizing some activities via custom instructions in each sequence.  The main use case is to have a primary NINA instance (server) handle mount operations and guiding and then synchronize with secondary instances (clients), so they can take exposures when the primary is but then wait while the primary is doing any mount operations (slew, dither).

By controlling target selection and exposure planning, Target Scheduler (TS) precludes using the existing instructions implemented by the Synchronization plugin.  There are several challenges but the primary block is that in TS, projects and targets explicitly belong to one NINA profile.  Since you can only run multiple instances of NINA if each is running a different profile, each instance would see a different set of active projects and targets.

To support synchronized acquisition, TS takes a different approach:
* The first instance of NINA that starts becomes the _sync server_ instance.  It will execute a sequence that is nearly identical to unsynchronized sequences using TS.
* Any instance of NINA started after the server becomes a _sync client_ and will communicate with the server to receive exposure details and other instructions.  Sync clients will run a truncated sequence script using different TS instructions unique to synchronization.
* All instances of NINA must be using a different NINA profile.  This is a requirement of NINA, not TS.
* The sequence instruction **_Target Scheduler Sync Wait_** can be used in either server or client sequences and serves to 'sync up' running instances to be sure all are ready for the next action.
* The sequence instruction **_Target Scheduler Sync Container_** is the sync client counterpart to **_Target Scheduler Container_**.  This instruction is used only in client sequences and handles communications with the server to poll for, accept, execute, and submit exposures.

One advantage of this approach is that since **_Target Scheduler Container_** and **_Target Scheduler Sync Container_** directly communicate, it's easier to keep exposures in lock-step on all instances, (hopefully) reducing wait times.  However, clients may periodically get out of sync with the server (e.g. when an autofocus is triggered on the client) but they should be able to re-sync on later exposures, depending on the timing.

## Assumptions

Proper operation of synchronization for Target Scheduler will assume the following:
* The primary goal of multiple OTAs/cameras on a single mount is to 'gang up' on the desired exposures for your targets and complete them faster.
* You can successfully run TS without synchronization.
* All NINA instances are running on the same Windows computer.
* Each NINA instance will be using a different NINA profile designed to support synchronization.
* The TS projects and targets you wish to image will be defined under the profile used by the server instance.
* The capabilities of the equipment used by each setup (server and all clients) are roughly equivalent.  This is most important for filter wheels (including filter naming) and somewhat less so for camera capabilities and focal lengths.
* Camera exposure settings such as gain, offset, binning, and readout mode can vary across the cameras used by leveraging the way Exposure Templates work for different profiles (see [below](#selection-of-exposure-templates)).
* The server instance should manage all safety related activities (e.g. park on unsafe, close roof, etc).
* The sequences used on all NINA instances will be customized to support synchronization.
* The TS projects/targets should handle dithering themselves and not rely on a Dither After Exposures trigger in the sequence.
* Be sure your PC can handle running two instances of NINA.  The [minimum system requirements](https://nighttime-imaging.eu/docs/master/site/requirements/) are for one instance, not two.  Some NUCs or other mini-PCs may have trouble running in synchronized mode.

## Getting Started

* Create NINA [profiles](#nina-profiles-for-synchronization) appropriate to your server and client instances.
* Create [sequences](#sequence-design-for-synchronization) for your server and client instances.
* Start NINA using the profile for the server instance.
* Start NINA using the profile for the client instance.

{: .note }
In this case, 'start NINA' means to run NINA itself (and select the appropriate profile).  The first instance started becomes the server; all others become clients.  _Running the sequence_ on any instance doesn't have any bearing on which is the server or client.

Once the server and client instances of NINA are running you can load the sequence appropriate to each and start the sequences.

See [Best Practices](#best-practices).  Also, consider using [scripted startup](#scripted-startup) to automate the start up process.

## Synchronization Instructions

### Target Scheduler Sync Wait

The **_Target Scheduler Sync Wait_** instruction provides a mechanism to synchronize activities between the server and clients.  When a sequence runs, this instruction will:
* Server: waits for all clients to enter the _wait_ state.  It then directs the clients to continue and then waits for all clients to report that they are again ready.
* Client: sets its state to _wait_ and then polls the server until the server reports the wait is completed.

Both server and clients will abort this process after some time period.  This defaults to 5 minutes and can be changed with the [Wait Timeout](target-management/profiles.html#synchronization-preferences) profile property.

In general, there must be a 1-1 relationship between Target Scheduler Sync Wait instructions across all sequences so that they stay in sync.

### Target Scheduler Sync Container

The **_Target Scheduler Sync Container_** instruction is used only in client sequences and should be added so that it runs at the same time as a corresponding Target Scheduler Container instruction in the server sequence.  This can be done with one or more Target Scheduler Sync Wait instructions.

This instruction will poll the server until the server is ready to send an exposure (or other action).  In the case of an exposure, the following happens on the client:
* Exposure is accepted and the server is notified
* Camera readout mode is set and filter is switched (if needed)
* Exposure is taken
* Image is graded (see below for more details on [client-side image grading](#image-grading))
* Server is informed of the completed exposure
* Client returns to polling

On the server side, the Target Scheduler Container will manage the process of sending exposure details to clients and waiting on completion.  The server will stop waiting for clients to accept the exposure after some time period.  This defaults to 5 minutes and can be changed with the [Action Timeout](target-management/profiles.html#synchronization-preferences) profile property.

If the scheduler returns an empty plan then imaging is done for the night and the server informs the clients which will then end the Target Scheduler Sync Container instruction.  Note that there is no timeout for the client-side polling: it will continue until the server informs it of scheduler completion for the night or the sequence is interrupted.

## Slew/Center/Rotate

The server instance will execute the slew/center at the start of a new target as usual.  Assuming server and client are in sync, the client will be doing nothing during this operation - simply waiting on the next action from the server.

However, if the server has a rotator connected, it will perform the slew/center/rotate and then inform the client that it needs to perform a solve/rotate.  If the client also has a rotator connected, it will execute the operation.  The server will wait for this to complete (or time out) before continuing with exposures.

## Custom Event Containers
You can add [custom event containers](sequencer/container.html#custom-event-instructions) to the Target Scheduler Sync Container instruction just like Target Scheduler Container.  When the server detects that it's time to run a specific event container, it will alert the client which will pick it up as the next action to run.  When done, the client will inform the server which will then continue.  Note that the client will be alerted regardless of whether the server has instructions in its corresponding container or not.

## Selection of Exposure Templates

When a client is given an exposure, details about the Target, Exposure Plan, and Exposure Template are provided.  In the TS database, these entities are associated with the profile being used for the server, not the client.  This is not a problem since the client can access the database as well as the server.  But it presents an opportunity to use different Exposure Templates in different cases.

The selection of the Exposure Template to use for each client exposure is done as follows:
* If the client profile defines an Exposure Template with the same name as that used by the server for this exposure, then the client's Exposure Template is used.  This lets clients adapt to different needs - for example a different camera.
* Otherwise, the Exposure Template from the server profile is used.

For example, if the exposure on the server is using the 'Lum' Exposure Template and the profile in use on the client also defines a 'Lum' Exposure Template, then the one on the client will be used.

### Usage Without a Filter Wheel

If you're not using a filter wheel on either your server or client instances, you can set up your Exposure Templates as described in [color cameras](target-management/exposure-templates.html#color-cameras).  You could also use a monochrome camera and filter wheel on your server instance with a client running a color camera:
* In your client profile, set up your filter wheel and exposure templates as discussed in [color cameras](target-management/exposure-templates.html#color-cameras).  You'll need dummy entries for all filters that might be scheduled on the server instance.  Be sure the names match exactly.
* Don't connect a filter wheel in your client sequence and any switch filter instructions will simply be ignored.

When the client receives an exposure, it will look up the Exposure Template of the same name (as discussed above) and use it.  As usual, it's best if the exposure times for the client are less than or equal to the server exposure times for each filter.

## Exposure Planning

The system that determines what exposures to take during a given target plan window is unchanged for synchronized operation and might result in taking more exposures than desired.  For example, your plan has 20 Lum exposures remaining of 3 minutes each and a one hour plan window.  The exposure planner will fill that window with 20 exposures.  However, with a server and one client, you might take nearly 40 exposures in that one hour period.  Since the planner won't run until the next planning window, you will have overshot the number of desired images and potentially wasted time.

This may be addressed in a future release.  For now, you can just reduce the number of desired exposures in your plans if you're running synchronized.

## Image Grading

Grading for images captured on the client is done by that client instance.  It will (mostly) operate as usual, determining if the image is acceptable or not, writing the record to the [Acquired Images](post-acquisition/acquisition-data.html) table, and updating the applicable Exposure Plan.

Two changes are required to support synchronization:
* Since there is no guider attached to a client instance, there is no RMS metadata available so grading on RMS is skipped.
* Since the equipment on the client instance (focal length, camera) may differ from the server and other clients, the set of comparison images must be further filtered to only compare against images for the same profile ID.

Grading on the server is unchanged.  Note that the counts in your Exposure Plans for your target in the server profile will reflect images taken across all NINA instances.


## NINA Profiles for Synchronization

The profile for the sync server should be able to connect to all the equipment you typically use: camera, focuser, mount, filter wheel, guider, etc.  As usual with TS, you should have your profile Filter configuration correct and stable.  The projects and targets you wish to image must be defined under this profile in TS Target Management since it will drive target selection.

Profiles used for sync clients only need to be able to connect to the camera, focuser, filter wheel, and (optionally) a rotator.  They should never connect to the mount or the guider.

All profiles used for synchronization must be enabled for it.  See the **Enable Synchronization** flag in [Profile Preferences](target-management/profiles.html#synchronization-preferences). 

If the OTAs/cameras on server and clients are different (e.g. different focal lengths), you may want to define different Image File Patterns (Options > Imaging > Image File Pattern) on server and clients so that you can easily segregate images.

It's not strictly required, but it's best to have filter offsets configured to avoid filter switch autofocus triggers.  If you don't, it's recommended to set Filter Switch Frequency to zero on your projects which should minimize this.

To avoid having NINA start automatically with the last profile used, it's best to set Options > General > Profile Chooser on Startup to ON for all profiles used for synchronization.  You can then easily control which profiles are loaded in which order.

## Sequence Design for Synchronization

The sequence used for the sync server is nearly identical to a sequence using TS in unsynchronized mode.  The only difference is typically the addition of **_Target Scheduler Sync Wait_** instructions to coordinate execution with clients.

For example, you probably want to have a prep phase where you get the mount pointed to a suitable location for focusing and then run an autofocus.  If you surround this with **_Target Scheduler Sync Wait_** instructions, you can have clients perform an autofocus at the same time, pointing at the same location.

### Basic Sequence for a Sync Server

When creating sequences for a sync server, you should start from an existing sequence that successfully runs TS.  Typically, the only modification is to place **_Target Scheduler Sync Wait_** instructions at appropriate locations.

A basic sequence to run on a sync server is shown below.  This is completely minimal and only focuses on actions related to synchronization.  In a real sequence, you would likely have a number of triggers in the _Image Server_ Sequential Instruction Set, for example Meridian Flip and various autofocus triggers.

Note the use of the Sync Wait instructions in the _Prep Server_ container.  These serve to synchronize an initial autofocus operation between server and clients.

```
Sequence Start Area
  Connect Equipment <all typically used>
  Cool Camera
Sequential Instruction Set: Prep Server
  Wait For <darkness>
  Target Scheduler Sync Wait
  Slew To <autofocus location>
  Target Scheduler Sync Wait
  Autofocus
  Target Scheduler Sync Wait
Sequential Instruction Set: Image Server
  Target Scheduler Container
Sequence End Area
  Warm Camera
  Park Scope
  Disconnect Equipment
```

### Basic Sequence for a Sync Client

Sequences for sync clients are simple compared to a server sequence since they don't have to deal with any operations associated with the mount (which includes dithering, roof/dome movement, and safety) or guiding.  However, they must have a matching number of Sync Wait instructions (compared to the server) and use the **_Target Scheduler Sync Container_** instruction sequenced to run at the same time as the **_Target Scheduler Container_** instruction on the server.

A basic sequence to run on a sync client is shown below.  Again, this is completely minimal, only focusing on actions related to synchronization.

Note the same number of Sync Wait instructions in the _Prep Server_ container - exactly matching those in the server example above.

```
Sequence Start Area
  Connect Equipment <only camera, focuser, filter wheet>
  Cool Camera
Sequential Instruction Set: Prep Client
  Target Scheduler Sync Wait
  Target Scheduler Sync Wait
  Autofocus
  Target Scheduler Sync Wait
Sequential Instruction Set: Image Client
  Target Scheduler Sync Container
Sequence End Area
  Warm Camera
  Disconnect Equipment
```

Note that a sync client can use the [Target Scheduler Condition](sequencer/condition.html) instruction.  In this case, the condition checks for _While Targets Remain Tonight_ and _While Active Projects Remain_ will query the projects and targets associated with the server instance.

## Best Practices

* Be sure you understand how NINA instances become a server or a client.  The first NINA instance executed (e.g. double-clicking the NINA icon) will become a server if the profile you select is enabled for synchronization.  Any NINA instances executed after the server automatically become clients (assuming their profiles are also enabled for synchronization).  Determination of server/client has nothing to do with when sequences are started in any instance.
* If you used the older Synchronization plugin in the past, be sure you remove any of those instructions (Synchronized Wait or Synchronized Dither) from your TS sequences.  You don't want to be mixing those with the TS sync instructions.
* In general, you should have matching **_Target Scheduler Sync Wait_** instructions in server and client sequences so that server/client operations stay in sync.
* Although you can place the **_Target Scheduler Sync Container_** inside another container in your client sequence, there is no need to use looping or use **_Target Scheduler Condition_** on that container.  Once **_Target Scheduler Sync Container_** starts, it will continue running until the server indicates it's done for the night or the sequence is canceled.  (Advanced sequences involving safety concerns may have different needs - TBD.)

## Scripted Startup

You can automate startup for synchronized operation using NINA command line options.  The &minus;&minus;profileid (or &minus;p) will start NINA using the specified profile (skipping the profile chooser).  Use &minus;&minus;sequencefile (or &minus;s) to load your sequence files.  When starting both server and client instances from the same script, you should use a delay (e.g. 10 seconds) after the server before starting a client.  Use 'NINA.exe &minus;&minus;help' to show all command line options.

You're on your own in creating such a script - it's beyond the scope of this documentation.

## Technical Details

### Communications

[Grpc](https://grpc.io/) is used for low-level interprocess (NINA to NINA) communications.  This is the same RPC framework used by the existing Synchronization plugin and is modeled loosely on that approach (at least at a low level).

Grpc is a RPC client/server (not peer-to-peer) protocol: clients can make requests to the server but not vice-versa.  For this reason, clients have to poll the server when waiting for instructions.  If the server has something for the client to do, it can return instructions in the response.  Otherwise, the client would continue waiting/polling.

In the TS implementation (as in the Synchronization plugin), one NINA instance will be the server, known as the _sync server_ instance.  In TS, the first NINA instance to start will automatically be selected as the sync server.  Any additional NINA instances started will automatically become _sync client_ instances and will register themselves as clients with the server.  'Starting' in this context just means starting NINA, not starting a sequence.

Clients have a background 'keepalive' thread that periodically calls the server so that the server knows it is still active and what state it is in.  If a client fails to check in after some period of time, it will be considered stale and removed from the server's client list.

This implementation uses Windows Named Pipes as the underlying communications mechanism (again, same as the existing Synchronization plugin).

### Logging

Target Scheduler writes log messages to a [different log file](technical-details.html#logging) than NINA to simplify analysis.  Server and client instances of NINA will of course write separate log files.  The synchronization operations for TS are quite verbose to support troubleshooting, with messages typically prepended with 'SYNC'.

### Polling Periods and Timeouts

The following constants are used in the code to determine the timing of various polling periods and timeouts.  These cannot be changed by the user.

|Item|Type|Default| Description                                                                                                                                                                |
|:--|:--|:--|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|SERVER_WAIT_POLL_PERIOD|millisecs|500| Poll period used by the server when checking for clients to report wait and then to report ready.                                                                          |
|SERVER_STALE_CLIENT_PURGE_CHECK_PERIOD|millisecs|3000| Poll period used by the server when checking for stale (dead) clients.                                                                                                     |
|SERVER_STALE_CLIENT_PURGE_TIMEOUT|seconds|10| Grace period for clients to report active before being purged.                                                                                                             |
|SERVER_AWAIT_EXPOSURE_POLL_PERIOD|millisecs|1000| Poll period used by the server when waiting for all clients to accept an exposure.                                                                                         |
|SERVER_AWAIT_EXPOSURE_COMPLETE_POLL_PERIOD|millisecs|1000| Poll period used by the server when waiting for all clients to complete an exposure.                                                                                       |
|SERVER_AWAIT_EXPOSURE_COMPLETE_TIMEOUT|seconds|30| Timeout when waiting for all clients to complete an exposure.  Since the server will have completed the same exposure, clients should finish the same exposure soon after. |
|SERVER_AWAIT_SOLVEROTATE_POLL_PERIOD|millisecs|1000| Poll period used by the server when waiting for clients to accept a solve/rotate.                                                                                          |
|SERVER_AWAIT_SOLVEROTATE_COMPLETE_POLL_PERIOD|millisecs|1000| Poll period used by the server when waiting for clients to complete a solve/rotate.                                                                                        |
|SERVER_AWAIT_EVENTCONTAINER_POLL_PERIOD|millisecs|1000| Poll period used by the server when waiting for clients to complete an event container.                                                                                    |
|CLIENT_KEEPALIVE_PERIOD|millisecs|3000| Poll period used by clients to report current state.                                                                                                                       |
|CLIENT_WAIT_POLL_PERIOD|millisecs|1000| Poll period used by clients when waiting for completion of a sync wait.                                                                                                    |
|CLIENT_ACTION_READY_POLL_PERIOD|millisecs|3000| Poll period used by clients when waiting for an action (exposure or solve/rotate).                                                                                         |
