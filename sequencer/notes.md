---
layout: default
title: Sequence Item Notes
parent: Advanced Sequencer
nav_order: 6
---

# Sequence Item Notes

## Attempts and Error Behavior

When you add instructions to the NINA advanced sequencer, you have the option to set the number of times an instruction will attempt execution and the behavior when the count is exceeded.
- All instructions added internally to image a target (slew/center, switch filter, take exposure, etc) will use the NINA default: attempts = 1 and error behavior = continue.
- Any center (plate solve) operation will use the number of attempts defined in the NINA profile (Options > Plate Solving > Number of attempts).

## Core Sequence Items

### Instructions

#### Camera
Other than cooling and warming, you shouldn't have to use any of the camera instructions since all exposures are managed by the Target Scheduler Container.

#### Dome
The dome instructions should work as expected.  However, the interactions between a dome, the mount, targeting, and safety are complex and must be tested for your particular equipment and configuration.

#### Filter Wheel
The Switch Filter instruction can be used outside of Target Scheduler Container (for example to set the filter for initial focusing).  However, filter switching for targets and exposures managed by Target Scheduler Container is handled internally.

#### Flat Panel
Any Flat Panel instructions outside of Target Scheduler Container should work as expected.

#### Focuser
Any focuser instructions outside of Target Scheduler Container should work as expected.

#### Guider
Any guider instructions outside of Target Scheduler Container should work as expected.

#### Rotator
Although any rotator instructions outside of Target Scheduler Container should work as expected, in general you shouldn't have to add them explicitly since the rotator will be managed internally when the slew/center operation is performed for a new target (if the target sets a non-zero rotation angle).

#### Safety Monitor
Any safety related instructions should work **_but must be thoroughly tested_**.

#### Switch
Any switch instructions outside of Target Scheduler Container should work as expected.

#### Telescope
Any telescope instructions outside of Target Scheduler Container should work as expected.  However, the slew/center operations for targets managed by the plugin are handled internally.

#### Utility
Any utility instructions outside of Target Scheduler Container should work as expected.  Some of the 'Wait' instructions may be appropriate in containers above Target Scheduler Container in the sequence hierarchy.  However, those used to control imaging start/stop times are typically not needed since target visibility is managed by the Planning Engine.  This is certainly true of **Wait Until Above Horizon**.

### Loop Conditions
It may be appropriate to add loop conditions to containers above Target Scheduler Container in the sequence hierarchy.  This is often used to handle global concerns (Loop While Safe) or to run a sequence over multiple days (e.g. using the [Target Scheduler Condition](condition.html)).

However, there is no need for the typical loop conditions that manage target start/stop times since these are handled by the Planning Engine.

### Triggers
In general, you should add triggers to the Sequential Sequence container immediately surrounding the Target Scheduler Container (and **_not_** the Triggers section under Target Scheduler Container).  They will typically present a better user experience when placed there.

Some triggers need to know the current target and since Target Scheduler Container can switch targets many times throughout a session, this might be a problem.  In particular:
* **Center After Drift**.  Should be added to the Sequential Sequence container immediately surrounding the Target Scheduler Container.  It will be detected when placed there and the current target will be sent to it each time a new target is returned by the planner. 
* **Meridian Flip**.  Can really be added anywhere above Target Scheduler Container since it will fall back to using mount coordinates if it can't determine a target.

You can certainly add other triggers to the Triggers section under Target Scheduler Container but you'll need to test to ensure it's working as desired.

## Items Added By Other Plugins

NINA Plugins can of course add instructions, loop conditions, and triggers that can be used in your sequences.  In general, these will likely work as expected with the following caveats:
* The item should adhere to the NINA lifecycle for sequence items.
* The item should interact with other elements in the sequence using mechanisms typically used by core sequence items.

If a trigger added by a plugin needs to know the current target, it should be added directly to the Target Scheduler Container so it can work with the dynamic targets managed by that container.

{: .warning }
Usage of any sequence elements added by a plugin in a sequence using a Target Scheduler Container should be thoroughly tested before unattended use.
