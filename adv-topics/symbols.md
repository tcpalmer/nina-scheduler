---
layout: default
title: NINA Expressions and Variables
parent: Advanced Topics
nav_order: 3
---

# Expressions and Variables

{: .note}
If you used the Sequencer Powerups plugin in the past, many of these concepts migrated into the core in version 3.3 and users should migrate their usage.

NINA 3.3 and above supports the use of user and plugin-defined variables and expressions. Many core sequencer instructions were modified to use this system.

## Variables
Target Scheduler now implements several variables (aka symbols) that reflect the state of the scheduler. All variables are initialized to the default value and available as soon as the TS plugin loads.

{: .warning}
These variables will be in a state of flux while NINA 3.3 is still in the nightly release state. Expect changes.

| Name                        | Type        | Default    | When Set                             |
| --------------------------- |-------------| ---------- | ------------------------------------ |
| TS_Version                  | string      | TS version | plugin start                         |
| TS_ContainerRunning         | bool        | false      | container start/stop                 |
| TS_ContainerWaiting         | bool        | false      | waiting/done waiting for next target |
| TS_ContainerPaused          | bool        | false      | container paused/unpaused            |
| TS_ContainerLastStarted     | DateTime*   | -          | last container start time            |
| TS_ContainerLastStopped     | DateTime*   | -          | last container stop time             |
| TS_CurrentTargetName        | string      | -          | a target starts imaging              |
| TS_CurrentProjectName       | string      | -          | a target starts imaging              |
| TS_CurrentTargetCoordinates | Coordinates | -          | a target starts imaging              |
| TS_CurrentTargetRotation    | double      | -          | a target starts imaging              |
| TS_CurrentTargetStarted     | DateTime*   | -          | a target starts imaging              |
| TS_CurrentFilterName        | string      | -          | an exposure starts                   |
| TS_CurrentExposureLength    | double      | -          | an exposure starts                   |
| TS_NextTargetStart          | DateTime*   | -          | a wait starts                        |
| TS_NextTargetName           | string      | -          | a wait starts                        |
| TS_NextProjectName          | string      | -          | a wait starts                        |

<sup>*</sup>The DateTime variables are stored as real DateTime objects. At present, the core expression system does not handle these natively. In fact, it wants to treat time values as double seconds for use in expressions (since this code has its roots in the Sequencer Powerups plugin). I'm hoping the core system can evolve to handle DataTime as a native and convert to seconds as the usage context requires.

### Variable Resets
* All the 'current target/project' variables are cleared when a new target starts imaging, a wait starts, the container ends, or a reset occurs.
* TS_CurrentFilterName and TS_CurrentExposureLength are cleared when the exposure ends or a reset occurs.
* All the 'next target/project' variables are cleared when the wait ends or a reset occurs.
* All variables (with the exception of TS_Version, TS_ContainerLastStarted, and TS_ContainerLastStopped) are reset to the default values at the following times:
  * Container stop (TS container ends execution)
  * Sequence reset
  * Sequence stopped
  * TS container error

## Relation to Pub/Sub and Sequencer Powerups
The existing TS [pub/sub system](pub-sub.html) was leveraged almost exclusively by Sequencer Powerups (SP). It allowed SP to track the state of TS and interact more intelligently with it. At present, the pub/sub system is unchanged and should continue to work with existing SP or the [Sequencer+](https://github.com/palmito9/Nina.SequencerPlus) fork.

At some point, it may be possible to leverage the core expression system to perform the same function and eliminate reliance on pub/sub. However, it will take some additional changes to the expression system.
