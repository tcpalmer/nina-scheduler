---
layout: default
title: Advanced Sequencer
nav_order: 7
has_children: true
---

{: .warning }
The plugin is still in a preliminary release state and suitable only for beta testing.  Users should thoroughly test sequences before attempting unattended use.

# Usage with the Advanced Sequencer

The plugin provides a single new instruction for the NINA Advanced Sequencer: _Target Scheduler Container_.  This instruction replaces the Deep Sky Object Instruction Set container that you would typically use as the parent for your imaging instructions and triggers.  Triggers can be added to it as needed and should interact with the plugin as expected - for example various autofocus triggers, meridian flip, center after drift, etc.  See below for more information on triggers.

There is no need to add any loop conditions or instructions to the Target Scheduler Container (and that ability will be blocked in a later release).  Instead, the Target Scheduler Container handles looping internally, calling the Planning Engine as needed to get the next target. 

You can have a parent container (e.g. Sequential Instruction Set container) and add Target Scheduler Container to it.  This parent container may have loop conditions and/or triggers to handle safety and other global concerns.

See the [technical details](../technical-details.html#target-scheduler-container-operation) for more information.

## Triggers

Sequence triggers are generally used to either invoke some operation or interrupt execution based on the state of the software and the attached equipment.  Unlike the DSO Instruction Set container which has a fixed target for the duration of an imaging session, the Target Scheduler Container may get a new target each time it calls the Planning Engine.  This poses challenges when using triggers that depend on knowing the coordinates of the current target.  In general, you should add such triggers directly inside the Target Scheduler Container so that they can query the container for the target.

However, this isn't always true.  Depending on the trigger implementation, it may fall back to other mechanisms.  For example, the Meridian Flip Trigger will query the mount for coordinates if it can't find a target in the sequence hierarchy.  Such triggers may work fine when added outside of the Target Scheduler Container.

{: .warning }
The plugin has been tested with many of the core Trigger instructions (including those like Meridian Flip Trigger and Center After Drift Trigger that depend on knowing the current target) and it works as expected.  However, other triggers - especially those added by other plugins - should be thoroughly tested before attempting unattended use.

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
      * Triggers: as needed (especially those that need to know the current target)
      * Loop Conditions: empty
      * Instructions: empty

* Typical wrap-up instructions in the Sequence End Area:
  * Warm Camera
  * Park mount
  * Disconnect Equipment

## Instruction User Interface

{: .note}
The instruction UI is somewhat primitive at this point but will improve over time.

The Target Scheduler Container interface in the advanced sequencer is similar to the core Deep Sky Object Instruction Set container - the main difference being that the target coordinates and altitude chart will update dynamically as the [Planning Engine](../concepts.html#planning-engine) returns new targets.

Before imaging begins, these elements will be empty.  When the instruction starts, the Planning Engine will be called and (if a target was selected), the elements will update to reflect that target.

In addition, the area below the chart will have a panel detailing the individual NINA instructions executed to implement the plan.  Each time the Planning Engine returns a new target to image, a new expandable line will be added.  This history will be retained for viewing until the sequence is reset.  It is not saved when you save a sequence file.

## Advanced Usage

Topics to be added in the future ...
* Usage with safety monitors
* Usage with the Synchronization plugin
* Multi-day sequences


