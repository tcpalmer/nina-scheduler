---
layout: default
title: Target Scheduler Condition
parent: Advanced Sequencer
nav_order: 2
---

# Target Scheduler Condition

When the Target Scheduler is used in more advanced sequences such as those supporting safety concerns or multi-night imaging, it becomes necessary to check the state of the projects and planner to determine when to break out of loops.  The Target Scheduler Condition is a loop condition that can be added to outer loops to achieve this.  It supports to two modes of operation: _While Targets Remain Tonight_ and _While Active Projects Remain_.

### When is the Condition Checked?

Unlike some core NINA conditions, Target Scheduler Condition will _not_ continuously check its condition every few seconds with a background process and then immediately interrupt the sequence (as it would for a safety condition).

But even NINA conditions without a background thread are checked after _every_ instruction completes.  That would be overkill in the case of Target Scheduler Condition since many of those instructions would be those automatically generated to image your targets.  We already know we have an active target at that point so there is no need to check the condition.

For that reason, Target Scheduler Condition will suppress its check if the originating instruction is determined to be coming from Target Scheduler execution.

Otherwise, the condition will be checked after completion of every other instruction in your sequence.

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
