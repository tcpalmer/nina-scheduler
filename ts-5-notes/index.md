---
layout: default
title: Target Scheduler 5 Notes
nav_order: 16
has_children: true
---

# Notes on Target Scheduler 5

Target Schedule 5 is a re-write of several major components of the plugin, including visibility determination, planning, and image grading.

{: .warning}
Before starting, be sure you understand the steps to [migrate](migration.html) to TS 5.

Major and minor changes are discussed below.  

### Planner

One of the more serious issues with TS 4 is that the project Minimum Time is not only used to set a minimum imaging time for a target, it’s also used to determine the length of each plan returned by the TS planner. So if your project minimum time is 30m, each plan returned for those targets will be constructed to take about 30m to execute. This causes a number of issues.
- In TS 4, you control the cadence of exposures and dithering with the project’s [Filter Switch Frequency](../target-management/projects.html#filter-switch-frequency) and [Dither Every](../target-management/projects.html#dithering) settings. Together, these determine a fixed ordering of exposures and dither operations (assuming you don’t override it). The cadence will be used to select exposures when building a plan. However, the cadence is reset to the start each time a plan for that target is generated. Depending on the length of the minimum time setting, this means that exposures early in the cadence accumulate more images and finish earlier than those later. It can also lead to unnecessary dithering.
- The moon avoidance calculations use the mid-point time of the plan to determine the moon position and accept/reject exposures.  But of course the moon is moving throughout the plan and the decision could change.  This isn't a huge problem for classic avoidance since the moon-target separation doesn't change rapidly.  But it does matter when using advanced avoidance based on moon altitude - and especially for longer minimum times.
- If the planner decides that no targets can be imaged now but could be later, it will calculate a wait time until the first potential target is available.  However, that doesn't take into account moon avoidance.  TS 4 might decide to wait on a target that would ultimately be rejected because the moon at that future time has a greater impact.

The new [planner](../concepts/planning-engine.html) will decouple plans from project minimum time by planning for a _single exposure only_.  The TS Container will execute the instructions for a single exposure (which could include a slew/center if a new target, switch filter, set readout, expose) and then go back to the planner when that exposure is complete.  Advantages:
* Filter cadences for each target will be persisted.  This means that the fixed cadence will be obeyed when switching targets and even over the course of multiple imaging sessions.  This also applies when the cadence is manually overridden.
* The planner can take the exact conditions into account when each exposure is planned.  This is most important today for moon avoidance but other sky quality metrics could be considered in the future.
* The planner will still try to continue with the current target for the minimum time span as long as:
  * The current time is still within the initial minimum time window, accounting for the duration of the next exposure
  * Some incomplete exposure plans remain
  * Moon avoidance doesn't reject all remaining exposure plans
* When determining wait times, the planner will use an incremental sampling approach that will take future time moon avoidance into account.

Although target _thrashing_ (wasting time on slew/centers when indiscriminately switching targets) is a potential concern with single-exposure planning, in practice this is avoided via target minimum time, and scoring rules like Target Switch Penalty and Percent Complete.

### Visibility Determination
A critical part of planning is determining when targets can actually be imaged.  In TS 4, the approach used had issues if a target was visible, then passed behind some obstruction (tree, house) and then appeared again.  In this case, TS 4 might not detect that second visible span.

In TS 5, the planner determines each target’s altitude and azimuth from sunset to sunrise. The values are calculated at discrete intervals (every 10 seconds by default) and cached for performance.

The planner needs to determine if the target is above the horizon for (at least) an interval starting now and continuing for the target’s minimum time. In this case, the horizon altitude at any azimuth is the higher of:
* The NINA profile custom horizon (if defined and enabled) plus any optional horizon offset
* Or the project’s minimum altitude

Basic visibility is then a simple matter of checking for target altitude > horizon at each azimuth over the sampled time span.

### Smart Exposure Planning

TS 4 provided two ways to control the selection and ordering of exposures:
1. Use Filter Switch Frequency and Dither Every.
2. Override the exposure order manually.

TS 5 adds a third: [Smart Exposure Selection](../concepts/planning-engine.html#smart-exposure-selector), enabled with a flag on projects (just below Dither Every).  With this enabled, Filter Switch Frequency is ignored and exposures are selected based on a 'moon aversion score'.  Basically, the more stringent the moon avoidance criteria, the higher the score.  In this mode, when the planner decides on the next exposure it selects the one that:
- Is not complete
- Is not rejected
- Has the highest moon aversion score

If more than one exposure has the same score (within some small tolerance), the one with lowest percent complete is selected.

Basically, if it passes moon avoidance and has the highest score, then it should be prioritized over others since the current conditions should be taken advantage of for that filter.  For example, you configure a Luminance filter to have very strict moon avoidance criteria.  You also have some narrowband filters on the same target (say Ha) configured with more relaxed constraints.  If you're imaging on a night with low moon impact, the Luminance exposures will be prioritized over Ha and should be selected until complete or the conditions change.

The Dither Every setting on the project applies and will behave as you would expect.

#### Smart Exposure Order Scoring Rule

In some cases, you never want to image using any narrowband filter on any target if you could be taking advantage of minimal moon for wideband imaging.  Just using Smart Exposure Selection as described above would not prevent another target from being selected by scoring higher.  If that target is taking Ha exposures, you could end up taking those when the moon is new.

The [Smart Exposure Order](../concepts/planning-engine.html#scoring-rules) scoring rule will let you control that behavior.  On your projects that are using Smart Exposure Selection, you should enter a non-zero weight for this rule.  That will compare targets and favor those using Smart Exposure Selection and a higher moon aversion score on the planned exposure.

The Smart Exposure Order rule weight defaults to zero so be sure to adjust if you need it.

### Delayed Grading
The TS 4 [image grading](../post-acquisition/image-grader.html) approach is dependent on a small sample of images to determine whether a new image has unacceptable metrics or not.  If the initial images were taken under better than average conditions, then later images will likely be rejected and the planner will continue to schedule more exposures.

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
TS 5 adds a new section at the highest level: [Reporting](../post-acquisition/reporting.html).  This section displays acquisition details on the images acquired for a selected target.  For images acquired after TS 5 is installed, a thumbnail image is saved and will be shown.

Unfortunately, nothing will be shown for images acquired prior to TS 5 due to a needed database change.  Images acquired with TS 5 and later will show details and thumbnails.

## Minor Changes

In addition to small bug fixes, the following changes are also noteworthy.

#### TS Logging Level
TS 5 adds the ability to set the log level (trace, debug, info, warning, error) similar to the main NINA log.  This setting is in TS profile preferences, so the setting is independent of the NINA setting.  The level defaults to debug.

{: .note }
Debug level is probably sufficient for most usage.  However, if you have an issue it may take trace level output to troubleshoot the problem.  Just be aware that trace level is extremely verbose.

#### New 'After Each Exposure' Event Container
You can now add custom instructions to the 'After Each Exposure' event container.  The instructions in the container will execute after each exposure has completed the NINA image processing pipeline.

#### New 'After Target Complete' Event Container
You can now add custom instructions to the 'After Target Complete' event container.  The instructions in the container will execute after a target reaches 100% complete on all exposure plans.

#### Sync Client Take Multiple Exposures per Server Exposure
If you have configured exposure templates with the same name on sync client and server, and the client exposure length is less than the server, then the client will try to take multiple exposures while the server takes one.  For example if the server length is 3 minutes and the client is 1 minute, the client will take 3 images while the server takes 1.

#### Project Maximum Altitude
TS 5 adds the ability to reject a target if it's current altitude is greater than a maximum (set at the project level).  Some telescopes are susceptible to hitting the mount or tripod legs when pointing at high altitudes.  This basically implements a no-go circle around the zenith of radius equal to 90 minus the maximum value in degrees.

#### Smart Plan Window Removed
TS 4 had support for a Smart Plan Window which would try to determine a better stop time for the current target.  With the TS 5 single exposure planning approach, that's no longer needed and has been removed.

#### Simulated Execution
TS 5 adds the ability to run sequences using TS at any time of day and have any wait periods skipped while simulating advancing time.  This can be enabled on the Profile settings page.

In general, this should only be used if you know what you're doing (e.g. a NINA developer).  In particular, the sequence should be minimal and not use any NINA or plugin instructions that depend on the current system time or wait for events (like twilight end).  Although Target Scheduler Condition can be used, Target Scheduler Background Condition cannot since it uses the current system time.

#### Enable/Disable Slew/Center
TS 5 adds the ability to skip the slew/center scheduled at the start of each new target: see the Enable slew/center flag in Profile preferences.  If disabled, Scheduler Preview will also show it skipped.  The assumption is that the user would handle it in the Before New Target event container.  TS will detect core NINA slew instructions there (e.g. Slew to RA/Dec) and inject the target coordinates.

#### Trigger Grading
You can now [trigger grading](../target-management/exposure-plans.html#manual-grading) for all exposure plans of a target.  Note that it runs in the background - you will have to refresh after a short period of time to see the results.

#### Other
* Added Exposure Template name to Acquired Images row detail view.
* Added database busy timeout to avoid locked errors.
* Added explicit display of regular or provisional percent complete on exposure plans.
* Location in sequence of a Center After Drift trigger is relaxed, can now be in any container above TS container.
* Added details to the message published when starting a planned wait: the next target and the number of seconds until the wait ends (developers only).
* Added ability to set the number of flats to take in the TS Flats instructions.
