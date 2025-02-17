---
layout: default
title: Target Scheduler 5 Beta
parent: Advanced Topics
nav_order: 4
---

# Target Scheduler 5: Beta Release

This page provides preliminary information on the TS 5 release during beta testing.  It does not cover all aspects of TS - for that refer to the [main documentation](../index.html).  However, other than the topics covered here, much of the plugin behavior remains the same.

{: .warning }
Read the section below on migration before proceeding!

Thanks in advance to all the beta testers.  If you have questions or find issues, please report on the Target Scheduler channel in NINA Discord.

## Migration to TS 5

### Database

Several changes were made to the TS database and an automatic database migration will be performed at NINA start the first time the beta runs.  However, to support rollback to TS 4, a copy of your TS database is saved to %localappdata%\NINA\SchedulerPlugin\schedulerdb-backup-pre-ts5.sqlite prior to the migration.  If you need to rollback, see [Rollback to TS 4](#rollback-to-ts-4) below.

If you have a large TS database - and particularly if you have a large number of acquired images - the migration can be slow, taking many 10s of seconds.  Subsequent NINA starts will behave normally.  NINA notifications will be displayed when the migration starts and ends.

### Sequence Files

During the development process, multiple classes changed name spaces.  Although this is typically transparent to the user, it does impact existing NINA sequence files since the fully qualified class name is used to refer to sequence items.  Note that this also applies to any sequence templates you have that refer to TS instructions.

You have two options to convert your sequence/template files.

#### Replace Existing Sequence Items
If you load a sequence that referred to TS 4 instructions, you'll see errors where NINA couldn't recognise the item.  You can just delete each of those and replace with the same item from the Sequence Instruction list.  To support rollback to TS 4, you should save the corrected version as a copy.

#### Automatic via Script
A simple Windows Powershell script is provided to rewrite sequence files to use the new TS names.  You can download the script [here](../assets/sequenceToTS5.ps1).  Follow these steps to run the script (assumes familiarity with running Windows Powershell scripts):
1. Move the script to the folder where you typically store sequence files, typically your Documents\N.I.N.A.
2. Open a Powershell command window.
3. Change directory to the same one storing your sequence or template files.
4. Run the script for each of your existing TS 4 sequence files:

```
sequenceToTS5.ps1 -file NAME.json -out NAME-TS5.json
```

The script won't overwrite your existing file - you have to provide a new name for the migrated copy.

## Major Changes

### Planner

One of the more serious issues with TS 4 is that the project Minimum Time is not only used to set a minimum imaging time for a target, it’s also used to determine the length of each plan returned by the TS planner. So if your project minimum time is 30m, each plan returned for those targets will be constructed to take about 30m to execute. This causes a number of issues.
- In TS 4, you control the cadence of exposures and dithering with the project’s [Filter Switch Frequency](../target-management/projects.html#filter-switch-frequency) and [Dither Every](../target-management/projects.html#dithering) settings. Together, these determine a fixed ordering of exposures and dither operations (assuming you don’t override it). The cadence will be used to select exposures when building a plan. However, the cadence is reset to the start each time a plan for that target is generated. Depending on the length of the minimum time setting, this means that exposures early in the cadence accumulate more images and finish earlier than those later. It can also lead to unnecessary dithering.
- The moon avoidance calculations use the mid-point time of the plan to determine the moon position and accept/reject exposures.  But of course the moon is moving throughout the plan and the decision could change.  This isn't a huge problem for classic avoidance since the moon-target separation doesn't change rapidly.  But it does matter when using advanced avoidance based on moon altitude - and especially for longer minimum times.
- If the planner decides that no targets can be imaged now but could be later, it will calculate a wait time until the first potential target is available.  However, that doesn't take into account moon avoidance.  TS 4 might decide to wait on a target that would ultimately be rejected because the moon at that future time has a greater impact.

The new planner will decouple plans from project minimum time by planning for a _single exposure only_.  The TS Container will execute the instructions for a single exposure (which could include a slew/center if a new target, switch filter, set readout, expose) and then go back to the planner when that exposure is complete.  Advantages:
* Filter cadences for each target will be persisted.  This means that the fixed cadence will be obeyed when switching targets and even over the course of multiple imaging sessions.  This also applies when the cadence is manually overridden.
* The planner can take the exact conditions into account when each exposure is planned.  This is most important today for moon avoidance but other sky quality metrics could be considered in the future.
* The planner will still try to continue with the current target for the minimum time span as long as:
  * The current time is still within the initial minimum time window, accounting for the duration of the next exposure
  * Some incomplete exposure plans remain
  * Moon avoidance doesn't reject all remaining exposure plans
* When determining wait times, the planner will use an incremental sampling approach that will take future time moon avoidance into account.

Although target _thrashing_ (wasting time on slew/centers when indiscriminately switching targets) is a potential concern with single-exposure planning, in practice this is avoided via target scoring rules like Target Switch Penalty and Percent Complete.

### Smart Exposure Planning

TS 4 provided two ways to control the selection and ordering of exposures:
1. Use Filter Switch Frequency and Dither Every.
2. Override the exposure order manually.

TS 5 adds a third: _Smart Exposure Selection_, enabled with a flag on projects (just below Dither Every).  With this enabled, Filter Switch Frequency is ignored and exposures are selected based on a 'moon aversion score'.  Basically, the more stringent the moon avoidance criteria, the higher the score.  In this mode, when the planner decides on the next exposure it selects the one that:
- Is not complete
- Is not rejected
- Has the highest moon aversion score

Basically, if it passes moon avoidance and has the highest score, then it should be prioritized over others since the current conditions should be taken advantage of for that filter.  For example, you configure a Luminance filter to have very strict moon avoidance criteria.  You also have some narrowband filters on the same target (say Ha) configured with more relaxed constraints.  If you're imaging on a night with low moon impact, the Luminance exposures will be prioritized over Ha and should be selected until complete or the conditions change.

If you have multiple wideband filters configured with the same avoidance criteria, then the selection is random.

The Dither Every setting on the project applies and will behave as you would expect.

#### Smart Exposure Order Scoring Rule

In some cases, you never want to image using any narrowband filter on any target if you could be taking advantage of minimal moon for wideband imaging.  Just using Smart Exposure Selection as described above would not prevent another target from being selected by scoring higher.  If that target is taking Ha exposures, you could end up taking those when the moon is new.

A new scoring rule will let you control that behavior: _Smart Exposure Order_.  On your projects that are using Smart Exposure Selection, you should enter a non-zero weight for this rule.  That will compare targets and favor those using Smart Exposure Selection and a higher moon aversion score on the planned exposure.

The Smart Exposure Order rule weight defaults to zero so be sure to adjust if you need it.


### Delayed Grading
The current [image grading](../post-acquisition/image-grader.html) approach is dependent on a small sample of images to determine whether a new image has unacceptable metrics or not.  If the initial images were taken under better than average conditions, then later images will likely be rejected and the planner will continue to schedule more exposures.

TS 5 adds an option to delay grading until some percentage of images have been acquired.  At that time, a more representative set of exposures will be available and all images taken to that point can then be graded based on overall population statistics.  The delay threshold is enabled by default and set to 80% - you can change that on the [Profiles settings](../target-management/profiles.html) panel.

Note that delayed grading may have side effects.  For example if today you move rejected images to another folder, that might not be attempted until some time - perhaps days - later.  If the image had been moved or deleted, the move will silently fail.

### Grading Auto-accept Levels
You can now set thresholds in Profile settings to automatically accept images if the actual image metric is 'better than' (less than) the configured value.  This is available for HFR, FWHM, and Eccentricity (the latter two with Hocus Focus only).  If any of these values are configured to be greater than zero (the default), then the grader will operate as follows:
1. Grade based on guiding RMS.  If it fails, the image is rejected.
2. Grade based on star count.  If it fails, the image is rejected.
3. If the image HFR < HFR auto accept, then the HFR standard deviation test is skipped.  Otherwise, the normal standard deviation determination for HFR is used. 
5. If the image FWHM < FWHM auto accept, then the FWHM standard deviation test is skipped.  Otherwise, the normal standard deviation determination for FWHM is used. 
7. If the image Eccentricity < Eccentricity auto accept, then the Eccentricity standard deviation test is skipped.  Otherwise, the normal standard deviation determination for Eccentricity is used.

Note that the threshold values you enter will be particular to the imaging characteristics of your equipment and your average seeing conditions.

### Reporting
TS 5 adds a new section at the highest level: **_Reporting_**.  This section displays details on the images acquired for a given target/filter.  For images acquired after TS 5 is installed, a thumbnail image is saved and will be shown here.

Unfortunately, nothing will be shown for images acquired prior to TS 5 due to a needed database change.  Images acquired with TS 5 and later will show details and thumbnails.

{: .note }
For now, the new Reporting section should be considered a demonstration of what can be done.  At a minimum, I'll be adding a summary table detailing acquisition time per filter.  Suggestions for enhancements are welcome.


## Minor Changes
In addition to small bug fixes, the following changes are also noteworthy.

#### TS Logging Level
TS 5 adds the ability to set the log level (trace, debug, info, warning, error) similar to the main NINA log.  This setting is in TS profile preferences, so the setting is independent of the NINA setting.  The level defaults to debug.

{: .note }
Debug level is probably sufficient for most usage.  However, if you have an issue it may take trace level output to troubleshoot the problem.  Just be aware that trace level is extremely verbose.

#### Visibility Bug
In TS 4, target visibility determination is susceptible to a visibility gap problem: if the target moves behind an obstacle (tree, chimney) in your custom horizon and then later reappears, TS will not find that second visible timespan in some circumstances. In TS 5, the visibility algorithm has been completely rewritten to use a sampling approach which is both more accurate (within the sampling limits) as well as quicker.

#### Project Maximum Altitude
TS 5 adds the ability to reject a target if it's current altitude is greater than a maximum (set at the project level).  Some telescopes are susceptible to hitting the mount or tripod legs when pointing at high altitudes.  This basically implements a no-go circle around the zenith of radius equal to 90 minus the maximum value in degrees.

#### Smart Plan Window
TS 4 had support for a Smart Plan Window which would try to determine a better stop time for the current target.  With the TS 5 single exposure planning approach, that's no longer needed and has been removed.

#### Simulated Execution
TS 5 adds the ability to run sequences using TS at any time of day and have any wait periods skipped while simulating advancing time.  This can be enabled on the Profile settings page.

In general, this should only be used if you know what you're doing (e.g. a NINA developer).  In particular, the sequence should be minimal and not use any NINA or plugin instructions that depend on the current system time or wait for events (like twilight end).  Although Target Scheduler Condition can be used, Target Scheduler Background Condition cannot since it uses the current system time.

#### Enable/Disable Slew/Center
TS 5 adds the ability to skip the slew/center scheduled at the start of each new target: see the Enable slew/center flag in Profile preferences.  If disabled, Scheduler Preview will also show it skipped.  The assumption is that the user would handle it in the Before New Target event container.

## Known Issues
- Although the time to generate any given plan is about the same as in TS 4, the single-exposure approach means that the planner is run many more times over the course of a night.  If you have a large number of targets, then this might be noticeable - especially using Scheduler Preview.  There are some things that can be tuned if this is a significant problem.
- Running the previewer on a target will update the filter cadence of targets that are selected.  This will impact the next run in the sequencer since the cadence cycle will have advanced from the previous run.  Researching solutions.
- The Scheduler Preview View Details info is now ridiculously verbose and needs to be redone.  However, this is really only an issue for trace level log output.

## Rollback to TS 4

If you need to rollback to TS 4:

1. In NINA, uninstall the Target Scheduler plugin.
2. Go to Options > Plugin Repositories and change the URL back to the release channel: https://nighttime-imaging.eu/wp-json/nina/v1.
3. Go to Plugins > Available and install TS 4 **_BUT DO NOT CLICK RESTART NINA!_**
4. Stop NINA normally.
5. In a Windows File Explorer, go to %localappdata%\NINA\SchedulerPlugin.
6. Copy schedulerdb-backup-pre-ts5.sqlite to schedulerdb.sqlite.
7. Restart NINA.
8. Go to Plugins > Installed and confirm that TS is the latest version 4 and that your TS projects, targets, etc look OK.
9. Be sure to use the saved copies of your sequence files prior to the TS 5 updates.
