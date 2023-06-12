---
layout: default
title: Planning Engine
parent: Concepts
nav_order: 2
---

# Planning Engine

The Planning Engine executes a series of steps to pick the best target to image at the moment and then schedule the applicable exposures for that target.  It operates in phases and in the end, produces a _Target Plan_.

A Target Plan is either:
* A delay to tell the Target Scheduler instruction it needs to simply wait for target availability.  At the end of the delay, it will call the planner again.
* The selected target, instructions to run, and the start time and hard stop time.

The hard stop time is basically the end of visibility for the target (e.g. sets below horizon) and is used to abort the plan in case that time is exceeded.

The following sections detail the different phases of planner operation.

## Select Candidate Projects/Targets
* Retrieve the list of active projects for the current NINA profile from the database. 
* Reject those that can never rise at this latitude.
* Reject those that are already complete.

## Determine Target Visibility
Begin by finding the nighttime circumstances for the upcoming night (start/stop times for each level of twilight).

### For Each Target

1. Find the most inclusive level of twilight acceptable over all target exposure plans.  For example, if you have an exposure plan for Ha that is acceptable during astronomical twilight plus another for Lum that can only image at true nighttime, then the overall potential timespan is astronomical twilight start to astronomical twilight end.  This is the **_twilight time span_** for the target.

2. Based on date, location, and horizon settings, determine the target circumstance times: rise above horizon, transit, and set below horizon.  The rise/set times define the **_visibility time span_** for the target.  

3. Find the overlap of the twilight time span and the visibility time span.  This is the **_potential imaging time span_**.  If this time span is empty, reject the target.

4. If the project defines a meridian window, then clip the potential imaging time span to that window.  If there is no overlap after clipping, reject the target.  This is the **_imaging time span_** for the target.

5. If the current time is not inside the imaging time span, then we reject the target _but_ mark it as potentially acceptable at a later time.

6. If the time between now and the end of the imaging time span is less than the minimum imaging time set on the project, then reject the target.

Otherwise, the target can be imaged now and is accepted.  The list of all such targets is the **_refined candidate list_**.

## Moon Avoidance

For each target in the refined candidate list:

1. For each exposure plan/template, if it enables moon avoidance then calculate the angular separation between the target and the moon.  Apply the avoidance formula and reject those exposure plans that violate it.
2. If all exposure plans for a target were rejected, then reject the target.

## Nothing Available Now?

If all targets were rejected, then find all of those that would be available later in the night.  Of those, find the one with the earliest start time.  At this point, the plan is returned to the Target Scheduler instruction with a Target Plan directing it to wait until that time.

## Nothing Available At All?

If all targets were rejected and none will be available later, then return null to the Target Scheduler instruction.  This will end execution of the instruction and the sequence will just fall through to the next instruction.  The [Target Scheduler Condition](../sequencer/condition.html) using the 'While Targets Remain Tonight' mode can be used to check for this state in outer containers.

## Scoring Engine

If only a single candidate target remains, then it is the selected target.  Otherwise, run the _Scoring Engine_ (described below) to produce a winning target.

## Plan Window

A time span is determined for planning the sequence instructions for the selected target.  The span begins immediately and ends at a selected stop time.  The stop time is important because it helps to control when the current plan ends and therefore when the planning engine is called again.  Since circumstances may have changed at that point (e.g. a higher priority target is now visible), it is desirable to run the engine again and let it decide what is now best to image.  The cost of running the engine again is low since it runs quickly and if the same target as the previous is selected, the instruction will skip the slew/center operation.

Currently, the stop time is determined as follows:
* If the target is part of a project that is using a meridian window, then the stop time is the end of the window.
* Otherwise, it is simply the start time plus the minimum imaging time set for the project.

## Generate Sequence Instructions

For all exposure plans for the selected target that weren't rejected for moon avoidance or aren't appropriate for the twilight level, generate the set of sequence instructions to take those exposures.

The ordering of exposures is driven by the [Filter Switch Frequency](../target-management/projects.html#filter-switch-frequency) setting for the associated project.

The set of exposures is selected (based on exposure times) to fit within the plan window.  However, when Target Plans execute, they will almost always run longer than the plan window end time due to the execution of time-intensive triggers such as Meridian Flip, Center After Drift, or Autofocus.  In general, this is acceptable and of course the execution would be interrupted by the plan hard stop time if it runs past that.

If [dithering](../target-management/projects.html#dithering) is enabled for the project, then the sequence of planned exposures is analyzed and dither instructions are inserted at appropriate points.

At this point, the target, instructions, and start/hard stop time are added to the Target Plan and returned to the Target Scheduler instruction for execution.

## Scoring Engine

The Scheduler uses a Scoring Engine to select a target when multiple candidates are under consideration.  The engine executes a set of rules on each target to produce a score, with the highest score winning.  The applicable Project has a set of configurable weights that are used to modulate the application of each rule.

### Scoring Rules

The following rules are currently implemented:

|Rule Name|Default Weight|Description|
|:--|:--|:--|:--|
|Meridian Window Priority|75%|A target scores higher if the project it is associated with is using a Meridian Window to limit imaging time.  The rationale is to prefer targets using meridian windows since those windows are limited over the course of any imaging session.|
|Percent Complete|50%|A target scores higher based on its ratio of accepted to desired images over all exposure plans.  The rationale is to prefer completion of a project over starting acquisition of something new.|
|Project Priority|50%|A project can set priority to High, Normal, or Low.  Targets for that project will score higher or lower depending on the setting.|
|Setting Soonest|50%|A target scores higher based on how close it is to setting below either the minimum altitude or (if enabled) the custom horizon.  The rationale is to prefer targets that will set before others, implying less time remaining in the target's imaging season.|
|Target Switch Penalty|67%|A target scores higher if it is the same target as the one immediately preceding this run.  The rationale is that switching targets is expensive given the required slew/center time.|

A user can select different weights for each rule to achieve different goals.  Setting a weight to zero disables that rule entirely.

Note that the default weights for Meridian Window Priority and Target Switch Penalty are set higher than the others.  Missing a meridian window is a high opportunity cost since those windows are relatively 'scarce' during any session.  Switching targets is expensive given the slew/center time.

The engine is designed to be easily extended by adding additional rules.  There is a limit with approaches like this, however.  As the number of rules increases, the predictability of engine outcomes goes down - and predictability can be desirable.  As the number grows it might be appropriate for users to select a subset that work well and disable the others.  Several additional rules are under consideration - see the [roadmap](../roadmap.html#scoring-engine-rules).
