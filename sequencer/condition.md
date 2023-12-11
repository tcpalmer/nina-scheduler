---
layout: default
title: Target Scheduler Condition
parent: Advanced Sequencer
nav_order: 3
---

# Target Scheduler Condition

When the Target Scheduler is used in more advanced sequences such as those supporting safety concerns or multi-night imaging, it becomes necessary to check the state of the projects and planner to determine when to break out of loops.  The Target Scheduler Condition is a loop condition that can be added to outer loops to achieve this.  It supports three modes of operation: _While Targets Remain Tonight_, _While Active Projects Remain_ and _While Flats Needed_.

### When is the Condition Checked?

Unlike some core NINA conditions, Target Scheduler Condition will _not_ continuously check its condition every few seconds with a background process and then immediately interrupt the sequence (as it would for a safety condition).

Instead, the condition operates similar to the _Loop For Iterations_ NINA condition: it only runs the check after all instructions in the container have completed.  If the check indicates to continue, the instructions are reset and run for another iteration.

## While Targets Remain Tonight
This mode will continue the loop as long as the Planning Engine indicates that additional targets are available tonight (either now or by waiting).

This is the default and is more useful in safety scenarios.  For example:

```
Normal Sequence Start
Night Container
    Target Scheduler Condition: While Targets Remain Tonight
    Instructions
        Acquisition Container
            Loop While Safe
            Target Scheduler Condition: While Targets Remain Tonight
            Instructions
                Open Dome Shutter
                Unpark Scope
                Target Scheduler Container
    Manage Unsafe Container
        Loop While Unsafe
        Instructions
            Park Scope
            Close Dome Shutter
            Wait for 5 min
Normal Sequence End
```

In this example, Target Scheduler Condition is used twice.  The first will end the Night Container when no more targets are available for the night.  There is no need for another dawn time check since the scheduler will handle this implicitly.

The second usage in the Acquisition Container is needed to end that container and effectively skip to the Sequence End instructions when done for the night.

## While Active Projects Remain
This mode will continue as long as any active Projects remain.  An [active](../target-management/index.html#activeenabled) project is one that is on the active state and has at least one active target with at least one incomplete exposure plan.

{: .warning }
This mode should be used with care.  Since you may have an active project that can't be imaged for months due to the time of year, using this in a sequence designed for a single night might cause an infinite loop with the planner being called repeatedly until the sequence is manually stopped.  You should only use this in an outer loop designed for multi-night imaging that also includes instructions to wait until the following dusk.

## While Flats Needed

This mode will continue as long as the [Target Scheduler Flats](../flats.html#target-scheduler-flats) instruction has flats to take.  It does not apply to projects/targets setup for use with [Target Scheduler Immediate Flats](../flats.html#target-scheduler-immediate-flats).
