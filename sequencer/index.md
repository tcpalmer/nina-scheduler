---
layout: default
title: Advanced Sequencer
nav_order: 7
has_children: true
---

# Usage with the Advanced Sequencer

The plugin provides a single new instruction for the NINA Advanced Sequencer: _Target Scheduler_.  The instruction is placed into a Sequential Instruction set - typically as the only instruction and with no loop conditions.  Triggers can be added as needed and should interact with the plugin as expected - for example various autofocus triggers, meridian flip, center after drift, etc.

Other built-in instructions or instructions from other plugins that aren't involved in sequence looping/timing or target selection will likely work with Target Scheduler too - but should be tested.

## Sequence Construction

Sequences using the plugin are typically simpler than others since there is usually no need for explicit targets, complex looping, wait/start/stop time constraints, or exposure instructions.  Instead, all of those operations (to the extent necessary) are handled transparently by the plugin.

However, you will still need the following instructions in your sequence:
* Connect and disconnect equipment
* Unpark/park the mount
* Calibrate and start guiding (if using)
* Any triggers you would normally use such as autofocus, meridian flip, center after drift, or safety checks
* Although dithering can be handled by the plugin, you may opt to include a dithering instruction yourself

A simple sequence construction approach is the following:
* Typical startup instructions in the Sequence Start Area:
  * Connect Equipment
  * Cool Camera
  * Unpark mount
* A Sequential Instruction Set:
  * Triggers: as needed
  * Loop Conditions: empty
  * Instructions:
    * Target Scheduler
* Typical wrap-up instructions in the Sequence End Area:
  * Warm Camera
  * Park mount
  * Disconnect Equipment

## Instruction Interface

{: .note}
The display is somewhat primitive at this point but will improve over time.

The instruction interface includes the following elements:
* Name of the project/target currently active.
* The coordinates of that target.
* The time at which imaging on this target will end (and therefore the time the planner will be called again).
* The standard NINA altitude chart for the target at the present time.

Before imaging begins, these elements will be empty.  When the instruction starts, the [Planning Engine](../concepts.html#planning-engine) will be called and (if a target was selected), the elements will update.  In addition, the area below the chart will have an expandable panel detailing the individual NINA instructions executed to implement the plan.  Each time the Planning Engine returns a new target to image, a new expandable item will be added.  These will be retained for viewing until the sequence is reset.

## Advanced Usage

Topics to be added in the future ...
* Usage with safety monitors
* Usage with the Synchronization plugin
* Multi-day sequences


