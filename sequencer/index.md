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

There is no need to add any loop conditions or instructions to the Target Scheduler Container.  Instead, the Target Scheduler Container handles looping internally, calling the [Planning Engine](../concepts/planning-engine.html) as needed to get the next target.

You can have a parent container (e.g. Sequential Instruction Set container) and add Target Scheduler Container to it.  This parent container may have loop conditions and/or triggers to handle safety and other global concerns.  Containers above Target Scheduler Container in the sequence hierarchy may need to use the [Target Scheduler Condition](condition.html) loop condition to break out in certain scenarios.

See the [technical details](../technical-details.html#target-scheduler-container-operation) for more information.

## Interface

The following shows a Target Scheduler Container instruction after adding to a sequence but before the sequence is running.

![](../assets/images/tsc-1.png)

It consists of three main areas:
1. **Target Details**.  When the planner returns a target to image, the details - including the nighttime/altitude chart - will be displayed here.
2. **Plan Progress**.  Each plan returned by the planner will generate an expandable section here containing details on what is happening and what has been completed.
3. **Custom Triggers/Instructions**.  Expand the Triggers and other instruction containers to drag/drop other NINA sequence items as needed.

## Triggers

Sequence triggers are generally used to either invoke some operation or interrupt execution based on the state of the software and the attached equipment.  Unlike the DSO Instruction Set container which has a fixed target for the duration of an imaging session, the Target Scheduler Container may get a new target each time it calls the Planning Engine.  This poses challenges when using triggers that depend on knowing the coordinates of the current target.  In general, you should add such triggers directly inside the Target Scheduler Container so that they can query the container for the target.

However, this isn't always true.  Depending on the trigger implementation, it may fall back to other mechanisms.  For example, the Meridian Flip Trigger will query the mount for coordinates if it can't find a target in the sequence hierarchy.  Such triggers may work fine when added outside of the Target Scheduler Container.

### Trigger Best Practices

Typical best practice is to place only the Center After Drift trigger (if using) directly inside the Target Scheduler Container.  Not only will other core NINA triggers work fine when added in an outer container, but they will behave better in the UI.  For example, NINA will be able to validate them as usual (is a focuser connected?) and they will update over time properly.

{: .warning }
The plugin has been tested with many of the core Trigger instructions (including those like Meridian Flip Trigger and Center After Drift Trigger that depend on knowing the current target) and it works as expected.  However, other triggers - especially those added by other plugins - should be thoroughly tested before attempting unattended use.

## Custom Event Instructions

Four areas are provided to drag/drop sequence instructions for execution at specific times during planner operation:
* **Before Wait**: run before each wait operation.  For example, park the mount.
* **After Wait**: run after each wait operation.  For example, unpark the mount.
* **Before New Target**: run before each new or changed target begins imaging.  Instructions here will be run _after_ a slew/center so that items like autofocus can be performed pointing at the target.
* **After New Target**: run after each new or changed target completes imaging or is interrupted.

Expand the individual containers to add items and then drag/drop instructions to the drop area as usual.  In general, any NINA instruction can be added but you should always test before unattended operation.

Note that the Before/After New Target instructions will _only_ be executed when the target is new or changed from the previous plan.  Returning the same target is a common occurrence since the planner will often select the same target if nothing else is available.

A timeline shows precisely when the event containers will be executed:

![](../assets/images/planning-timeline-2.png)

### Custom Instruction Dos and Don'ts
* You can elect to use Park Scope in Begin Wait and Unpark Scope in After Wait.  If you do so, you should set the [Park on Wait](../target-management/profiles.html#profile-preferences) preference to false.  However, the benefit of using the preference is that it will skip the park/unpark if the wait period is less than a minute.  In contrast, doing this in Before/After Wait would park/unpark even for a five second wait.
* There is no need to add instructions to stop tracking or guiding at the start of a wait - that will be done automatically and will also restart when the next target begins.
* You should not add any instructions to take exposures.  Doing so would confuse the scheduler mechanism used to watch images as they progress through the regular NINA image pipeline.
* You should not add instructions in response to safety interrupts (park/unpark, close/open RoR, etc).  Instead, you should handle that logic in the regular safety portions of your sequence.
* You can conceivably add other containers (e.g. Sequential or Parallel Instruction Set) but this has not been extensively tested.
* If you use instructions added by other plugins, you should test extensively.

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
      * Custom Before/After Wait instructions
      * Custom Before/After New Target instructions

* Typical wrap-up instructions in the Sequence End Area:
  * Warm Camera
  * Park mount
  * Disconnect Equipment

## Instruction User Interface

The Target Scheduler Container interface in the advanced sequencer is similar to the core Deep Sky Object Instruction Set container - the main difference being that the target coordinates and altitude chart will update dynamically as the [Planning Engine](../concepts/planning-engine.html) returns new targets.

Before imaging begins, these elements will be empty.  When the instruction starts, the Planning Engine will be called and (if a target was selected), the elements will update to reflect that target.

In addition, the area below the chart will have a panel detailing the individual NINA instructions executed to implement the plan.  Each time the Planning Engine returns a new target to image, a new expandable line will be added.  This history will be retained for viewing until the sequence is reset.  It is not saved when you save a sequence file.

## Advanced Usage

Topics to be added in the future ...
* Usage with safety (weather) concerns
* Multi-day sequences
