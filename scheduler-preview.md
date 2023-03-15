---
layout: default
title: Scheduler Preview
nav_order: 7
---

# Scheduler Preview

You can preview schedules on the plugin home page (NINA Options > Plugins > Target Scheduler) by expanding the Scheduler Preview section.

Select a date/time and the desired profile to get started.  When you click the Run button, the planner will find all active projects for that profile and then determine the targets to image for that date.  The panel below will display the series of plans returned by the planner, showing each project/target with the associated instructions underneath (assuming at least one target meets the criteria).

{: .warning }
Previews are not meant to reflect the exact behavior of the sequence instruction.  Please read the following to understand how a preview differs from an actual run in the NINA Sequencer.

A preview works by first calling the [Planning Engine](concepts.html#planning-engine) with the date/time specified.  It than repeatedly calls the engine using the stop time of the previous target as the next start time, until no more targets are returned.  By doing this, it is assuming that the work for each target will run up until that stop time.  A preview also assumes that all images are acceptable.

However, the real instruction works quite differently:
* If it finishes executing all instructions for a target, it will stop and call the engine again to get the next target.
* More likely, the time required to execute those instructions _plus all applicable triggers_ will mean that the timeout trigger for the target will stop execution before all instructions are complete.
* In addition, acquired images are not assumed to be acceptable.  Instead, they will be graded by the [Image Grader](post-acquisition/image-grader.html) (if enabled) or left for the user to manually accept/reject.

Since nearly every sequence will have triggers to autofocus or handle meridian flips (both lengthy operations), target plans will rarely finish before the timeout trigger goes off.  This typically isn't an issue at runtime since the engine is called again and may well return to the same target - so there wouldn't even be the cost of a slew/center.
