---
layout: default
title: Plugin Communication
parent: Advanced Topics
nav_order: 2
---

# Communicating with Other Plugins

NINA provides the ability for one plugin to publish messages that can then be received and acted on by other plugins.  This section provides details for other plugin authors wishing to integrate with TS.

{: .warning }
This is an experimental feature available with the 4.8.0.0 release and later.  The timing and format of messages is likely to change.  Any changes will be made in coordination with collaborating plugin authors.

## TS Sender Details
TS messages will be identified by the following:
- MessageSenderId: B4541BA9-7B07-4D71-B8E1-6C73D4933EA0
- MessageSender: "Target Scheduler"
- SentAt: UTC Now (when message is composed/sent)
- TS is not currently using the CorrelationId message property

All messages sent from TS will be logged in the TS log at compose/send time.

## Starting a Wait
When the TS planner returns a 'wait' period (wait some amount of time for the next target to become available), it will publish a **_wait start_** message.

- Topic: TargetScheduler-WaitStart
- Version: 2
- Content: (DateTime) wait end time
- Expiration: wait end time
- Headers:
    - SecondsUntilNextTarget: (int) number of seconds to wait until the next target starts
    - ProjectName: (string) TS project name for the next target
    - TargetName: (string) TS name for the next target
    - Coordinates: (NINA.Astrometry.Coordinates) coordinates of the next target
    - Rotation: (double) next target rotation angle (as entered into the TS UI)


## Starting a New Target
When the TS planner returns a target plan _and_ the target is 'new' (see below), it will publish a **_new target start_** message.

- Topic: TargetScheduler-NewTargetStart
- Version: 2
- Content: (string) target name
- Expiration: target end time (see below)
- Headers:
    - ProjectName: (string) TS project name for the target
    - Coordinates: (NINA.Astrometry.Coordinates) coordinates of the target
    - Rotation: (double) target rotation angle (as entered into the TS UI)
    - ExposureFilterName: (string) name of the filter for the selected exposure 
    - ExposureLength: (double) length of the selected exposure in seconds
    - ExposureGain: (string) gain setting of the selected exposure or '(camera)' if defaults to camera setting
    - ExposureOffset: (string) offset setting of the selected exposure or '(camera)' if defaults to camera setting
    - ExposureBinning: (string) binning mode of the selected exposure, e.g. '1x1'

See below for details on when this message is sent.

## Starting a Target
When the TS planner returns a target plan, it will publish a **_target start_** message.  This is sent regardless of whether the target is new or not.

- Topic: TargetScheduler-TargetStart
- Version: 2
- Content: (string) target name
- Expiration: target end time (see below)
- Headers:
    - ProjectName: (string) TS project name for the target
    - Coordinates: (NINA.Astrometry.Coordinates) coordinates of the target
    - Rotation: (double) target rotation angle (as entered into the TS UI)
    - ExposureFilterName: (string) name of the filter for the selected exposure
    - ExposureLength: (double) length of the selected exposure in seconds
    - ExposureGain: (string) gain setting of the selected exposure or '(camera)' if defaults to camera setting
    - ExposureOffset: (string) offset setting of the selected exposure or '(camera)' if defaults to camera setting
    - ExposureBinning: (string) binning mode of the selected exposure, e.g. '1x1'

See below for details on when this message is sent.

## Container Stopped
When the TS Container instruction ends, it will publish a **_container stopped_** message.

- Topic: TargetScheduler-ContainerStopped
- Version: 1
- Content: (string) "Container Stopped"
- Expiration: n/a
- Headers:
  - StoppedAt: (DateTime) time that the container stopped


## Notes on Target Start Messages

### Order of Operations
TS will send the two types of target start messages in the following order:
- If the target is _new_, send the New Target Start message
- Send the Target Start message (always sent, regardless of whether new or not)
- Slew/center to the target (only if needed, e.g. target is new or TS was interrupted)
- Any instructions in the 'Before New Target' custom event container
- The regular plan instructions

A target plan is _new_ when:
- It is the first target of the night or
- It is different from the previous target or
- It is the first target after an interruption (e.g. safety interrupt)

### Target End Time
The target end time (in the message expiration field) should be used with caution.  The value used is the time at which the target loses visibility.  However, plans are designed to run within the project minimum time constraint and will contain only enough exposures to fill that time.  Most plans will continue running past the project minimum since plans may contain time consuming operations like slew/center, or be interrupted by auto focus triggers.  However, a plan is guaranteed to be stopped at the target end time since the target would no longer be visible after that time.

## Completing a Target
When the TS planner completes a target plan (all exposure plans 100% complete), it will publish a **_target complete_** message.

- Topic: TargetScheduler-TargetComplete
- Version: 1
- Content: (string) target name
- Expiration: none
- Headers:
  - ProjectName: (string) TS project name for the target
  - Coordinates: (NINA.Astrometry.Coordinates) coordinates of the target
  - Rotation: (double) target rotation angle (as entered into the TS UI)
