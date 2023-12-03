---
layout: default
title: Target Scheduler Container
parent: Advanced Sequencer
nav_order: 2
---

# Target Scheduler Container

The primary instruction associated with the plugin is _Target Scheduler Container_.  This instruction replaces the Deep Sky Object Instruction Set container that you would typically use as the parent for your imaging instructions and triggers.  Triggers can be added to it as needed and should interact with the plugin as expected - for example various autofocus triggers, meridian flip, center after drift, etc.  See below for more information on triggers.

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

Sequence triggers are generally used to either invoke some operation or interrupt execution based on the state of the software and the attached equipment.  Unlike the DSO Instruction Set container which has a fixed target for the duration of an imaging session, the Target Scheduler Container may get a new target each time it calls the Planning Engine.  This poses challenges when using triggers that depend on knowing the coordinates of the current target.  

In releases prior to 4.0.5.0, it was necessary to place the Center After Drift trigger into the Triggers list inside Target Scheduler Container so that it could follow the current target.  However, the code will now recognize a Center After Drift trigger placed into the same container that holds Target Scheduler Container and automatically update it when the target changes.  This provides a much better user experience since the trigger display updates properly.

At this point, it probably doesn't make sense to add any trigger to this list since all known triggers will work correctly and provide a better experience when placed outside Target Scheduler Container.  In fact, if you place a Center After Drift trigger there, it will ignore it and warn you.  The entire Triggers section may be removed in the future to avoid confusion.

## Custom Event Instructions

Five areas are provided to drag/drop sequence instructions for execution at specific times during planner operation:
* **Before Wait**: run before each wait operation.  For example, park the mount.
* **After Wait**: run after each wait operation.  For example, unpark the mount.
* **Before New Target**: run before each new or changed target begins imaging.  Instructions here will be run _after_ a slew/center so that items like autofocus can be performed pointing at the target.
* **After New Target**: run after each new or changed target completes imaging or is interrupted.
* **After Each Target**: run after every target plan, regardless of whether it's new or not.  An important use case of this is with the [Target Scheduler Immediate Flats](../flats.html#target-scheduler-immediate-flats) instruction.

Expand the individual containers to add items and then drag/drop instructions to the drop area as usual.  In general, any NINA instruction can be added but you should always test before unattended operation.

Note that the Before/After New Target instructions will _only_ be executed when the target is new or changed from the previous plan.  Returning to the same target is a common occurrence since the planner will often select the same target if nothing else is available.

If you're running [synchronized](../synchronization.html), these containers will run only on the server, not clients.

A timeline shows precisely when the event containers will be executed:

![](../assets/images/planning-timeline-2.png)

### Coordinates Injection

Some core NINA instructions assume that they can inherit target coordinates from the surrounding context - for example a parent DSO Container.  Since targets are dynamic with Target Scheduler, we have to take steps to inject the current target coordinates into those instructions if running as part of a custom event container.  For the _Before New Target_, _After New Target_, and _After Each Target_ containers, the following instructions (if found) will have this behavior:
* Slew To Ra/Dec
* Slew and center
* Slew, center and rotate

In general, you shouldn't have to add these instructions to an event container since Target Scheduler usually handles all target slewing for you.  However, when using Target Scheduler Immediate Flats with a wall panel flat device, you probably need Slew To Ra/Dec to return to the current target when the flats are complete.

### Custom Instruction Dos and Don'ts
* You can elect to use Park Scope in Begin Wait and Unpark Scope in After Wait.  If you do so, you should set the [Park on Wait](../target-management/profiles.html#profile-preferences) preference to false.  However, the benefit of using the preference is that it will skip the park/unpark if the wait period is less than a minute.  In contrast, doing this in Before/After Wait would park/unpark even for a five second wait.
* There is no need to add instructions to stop tracking or guiding at the start of a wait - that will be done automatically and will also restart when the next target begins.
* You should not add any instructions to take exposures.  Doing so would confuse the scheduler mechanism used to watch images as they progress through the regular NINA image pipeline.
* You should not add instructions in response to safety interrupts (park/unpark, close/open RoR, etc).  Instead, you should handle that logic in the regular safety portions of your sequence.
* You can conceivably add other containers (e.g. Sequential or Parallel Instruction Set) but this has not been extensively tested.
* If you use instructions added by other plugins, you should test extensively.

### Why Can't I have a Custom Event Container for X?

It might seem simple to add additional event containers - for example _After Each Exposure_ or _After Target Completed_.  However, due to the asynchronous nature of NINA's image processing, it's essentially impossible (at least for these two).  When an exposure has been downloaded from the camera, NINA starts a separate thread to finalize processing on the image (e.g. star detection, TS image grading, and moving it to the final location).  Immediately after that thread starts, NINA returns to regular instruction execution in your sequence.

The events for _After Each Exposure_ and _After Target Completed_ can only be triggered once that image processing thread has completed.  But at that point, the sequencer has moved on and we don't have access to run arbitrary instructions.  Certainly, many plugins perform operations after imaging processing is complete (as does Target Scheduler).  However, in those cases the logic is fixed - not arbitrary instructions as with a custom event container.


## Instruction User Interface

The Target Scheduler Container interface in the advanced sequencer is similar to the core Deep Sky Object Instruction Set container - the main difference being that the target coordinates and altitude chart will update dynamically as the [Planning Engine](../concepts/planning-engine.html) returns new targets.

Before imaging begins, these elements will be empty.  When the instruction starts, the Planning Engine will be called and (if a target was selected), the elements will update to reflect that target.

In addition, the area below the chart will have a panel detailing the individual NINA instructions executed to implement the plan.  Each time the Planning Engine returns a new target to image, a new expandable line will be added.  This history will be retained for viewing until the sequence is reset.  It is not saved when you save a sequence file.
