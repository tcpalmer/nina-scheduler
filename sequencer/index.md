---
layout: default
title: Advanced Sequencer
nav_order: 7
has_children: true
---

# Usage with the Advanced Sequencer

All Target Scheduler sequence instructions can be found under the "Target Scheduler" category in the sequencer interface.

The following instructions are implemented:
* [Target Scheduler Container](container.html).  This is the primary instruction associated with the plugin and typically replaces the Deep Sky Object Instruction Set container in your sequences.
* [Target Scheduler Condition](condition.html) is a loop condition that can break out of loop in circumstances related to scheduler operation.  This is mostly needed for more complex scenarios dealing with safety concerns or multi-night imaging.
* [Target Scheduler Background Condition](backgroundcondition.html) is a variant loop condition that will interrupt a sequence if it determines that no more targets remain for the night.
* [Target Scheduler Flats](flats.html#target-scheduler-flats) is used to take flat frames based on the lights taken recently for your targets.
* [Target Scheduler Immediate Flats](flats.html#target-scheduler-immediate-flats) is used to take flat frames based on the lights taken for a target you just imaged.
* [Target Scheduler Sync Container](../synchronization.html#target-scheduler-sync-container) is the counterpart to Target Scheduler Container and is used for synchronization.
* [Target Scheduler Sync Wait](../synchronization.html#target-scheduler-sync-wait) is used to sync NINA instances during synchronization.

## Sequence Construction

Sequences using the plugin are typically simpler than others since there is usually no need for explicit targets, complex looping, wait/start/stop time constraints, or exposure instructions.  Instead, all of those operations (to the extent necessary) are handled transparently by the plugin.

However, you will still need the following in your sequence:
* Connect and disconnect equipment
* Unpark/park the mount
* Calibrate and start guiding (if using)
* Any triggers you would normally use such as autofocus, meridian flip, center after drift, or safety checks
* Although dithering can be handled by the plugin, you may opt to include a dithering trigger yourself

See [Sequence Item Notes](notes.html) for details on using other sequence items (core or those added by other plugins) in your sequences.

A basic sequence construction approach is the following:
* Typical startup instructions in the Sequence Start Area:
    * Connect Equipment
    * Cool Camera
    * Unpark mount
* A Sequential Instruction Set:
    * Triggers: as needed (those that do not need to know the current target)
    * Loop Conditions: as needed but typically only for multi-day execution since the Target Scheduler Container will handle 'looping' until visibility ends for the night for all targets.
    * Instructions:
        * **Target Scheduler Container**:
            * Triggers: as needed (any that need to know the current target, typically only Center After Drift)
            * Custom Before/After Wait instructions
            * Custom Before/After New Target instructions

* Typical wrap-up instructions in the Sequence End Area:
    * Warm Camera
    * Park mount
    * Disconnect Equipment

## Advanced Usage

Topics to be added in the future ...
* Usage with safety (weather) concerns
* Multi-day sequences
