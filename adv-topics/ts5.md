---
layout: default
title: Target Scheduler 5
parent: Advanced Topics
nav_order: 3
---

# Target Scheduler 5

Version 4 of Target Scheduler works well in many situations for many users.  However, it does suffer from a number of issues.  TS 5 is a substantial rewrite of the plugin designed to address many of these problems.

TS 5 will first be available as beta some time in Q1 2025.  The code is still under development and things could change or problems arise that impact the ability to implement these items ... but this is the current plan.

As usual, the usual suspects in the very informal [TS advisory group](../index.html#acknowledgements) contributed to and advised on the new approaches.

## Planner

One of the more serious issues with TS 4 is that the project Minimum Time is not only used to set a minimum imaging time for a target, it's also used to determine the length of each plan returned by the TS planner.  So if your project minimum time is 30m, each plan returned for those targets will be constructed to take about 30m to execute.  This causes a number of issues.

### Problems with Current Approach

#### Filter Cadence

In TS 4, you control the cadence of exposures and dithering with the project's [Filter Switch Frequency](../target-management/projects.html#filter-switch-frequency) and [Dither Every](../target-management/projects.html#dithering) settings.  Together, these determine a fixed ordering of exposures and dither operations (assuming you don't override it).  The cadence will be used to select exposures when building a plan.  However, the cadence is reset to the start each time a plan for that target is generated.  Depending on the length of the minimum time setting, this means that exposures early in the cadence accumulate more images and finish earlier than those later.  It can also lead to unnecessary dithering.

#### Moon Avoidance

The moon avoidance calculations use the mid-point time of the plan to determine the moon position and accept/reject exposures.  But of course the moon is moving throughout the plan and the decision could change.  This isn't a huge problem for classic avoidance since the moon-target separation doesn't change rapidly.  But it does matter when using advanced avoidance based on moon altitude - and especially for longer minimum times.

#### Wait Times and Moon Avoidance

If the planner decides that no targets can be imaged now but could be later, it will calculate a wait time until the first potential target is available.  However, that doesn't take into account moon avoidance.  TS 4 might decide to wait on a target that would ultimately be rejected because the moon at that future time has a greater impact.

### New Planner

The new planner will decouple plans from project minimum time by planning for a _single exposure only_.  The TS Container will execute the instructions for a single exposure (which could include a slew/center if a new target, switch filter, set readout, expose) and then go back to the planner when that exposure is complete.  Advantages:
* Filter cadences for each target will be persisted.  This means that the fixed cadence will be obeyed when switching targets and even over the course of multiple imaging sessions.  This also applies when the cadence is manually overridden.
* The planner can take the exact conditions into account when each exposure is planned.  This is most important today for moon avoidance but other sky quality metrics could be considered in the future.
* When determining wait times, the planner will use an incremental sampling approach that will take future time moon avoidance into account.

Although target _thrashing_ (wasting time on slew/centers when indiscriminately switching targets) is a potential concern with single-exposure planning, in practice this is avoided via target scoring rules like Target Switch Penalty and Percent Complete.

## Visibility

In TS 4, target visibility determination is susceptible to a visibility gap problem: if the target moves behind an obstacle (tree, chimney) in your custom horizon and then later reappears, TS will generally not find that second visible timespan.  In TS 5, the visibility algorithm has been completely rewritten to use a sampling approach which is both more accurate (within the sampling limits) as well as quicker.

## Smart Exposure Selection

In addition to the current fixed filter cadence plus user override, TS 5 will support _smart exposure selection_.  In this mode, there is no fixed cadence.  Instead, exposures (filters) are selected dynamically based on a priority score determined from the moon avoidance settings.  A high priority exposure with more stringent avoidance (e.g. Lum) will be selected over those with more relaxed settings (e.g. Ha) when the moon allows.

The project's Dither Every setting will still be obeyed when smart exposure selection is used.

A new target scoring rule may also be added to help prioritize targets using smart exposure selection.  For example, if the moon allows, you may never want to select a target doing narrowband imaging when another could be taking wideband exposures.

## Image Grading

The current [image grading](../post-acquisition/image-grader.html) approach is dependent on a small sample of images to determine whether a new image has unacceptable metrics or not.  If the initial images were taken under better than average conditions, then later images will likely be rejected and the planner will continue to schedule more exposures.

In TS 5, there will be an option to delay grading until some percentage (e.g. 90%) of images have been acquired.  At that time, a more representative set of exposures will be available and all images taken to that point can then be graded based on overall population statistics.

Note that delayed grading will have side effects.  For example if today you move rejected images to another folder, that might not be attempted until some time - perhaps days - later.

Even with this improvement, grading in TS should never be the final decision on whether an image is acceptable or not.  You should always review your images and use more sophisticated (external) methods.

### Asynchronous Image Grading

In TS 4, at the end of a plan (which likely includes multiple exposures), we had to wait for all images to come through the image save pipeline before proceeding to the next plan.  This was necessary so that the exposure plan database records could be updated with the results of grading and exposure selections for the next plan could take that into account.  Depending on various conditions (speed of the hardware, whether CenterAfterDrift had to platesolve, etc) this delay could actually be quite lengthy - even 10s of seconds.

In TS 5 with single-exposure planning, this would be even worse since we'd have to perform this wait after _every_ exposure.  To prevent that (and actually improve on TS 4), TS 5 will queue-up grading tasks to be run asynchronously and let the planner/sequencer continue.  This also makes sense in the context of delayed grading since the work might be substantial when the percentage threshold is finally reached.

The downside is that the planner may sometimes execute before exposure plan records have been updated.  When an exposure plan is nearing completion, the planner may decide that it needs one more image when in fact, the grader may be about to accept another and mark that plan complete.  However, occasionally taking one more image than desired is a small price given the overall increase in planner throughput.

## Migration Plan

The database for TS 5 has a number of changes that will not be backwards compatible with TS 4.  For that reason, a onetime 4-to-5 migration will be supported:
* When TS 5 runs for the first time and finds a TS 4 database, it will migrate it to a new TS 5 database file in a new plugin directory.  Nothing in the legacy TS 4 directory (including the database) will be touched.  This means you could easily revert back to TS 4 and only lose changes or exposure progress made in TS 5.
* If you reverted to TS 4 but later wanted to move to TS 5 again, you could just remove any existing TS 5 plugin directory and the onetime migration will be redone.
* Sequences created for TS 4 should work as-is with TS 5.
* Synchronized execution should remain unchanged.

Other than a handful of changes to support new features, the user interface for managing TS projects, targets, exposures, etc will remain essentially the same.

