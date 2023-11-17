---
layout: default
title: Release Notes
nav_order: 12
---

# Release Notes 4.0.5.0

## Changes in this Release

This release is available for NINA 3.  Only fixes for serious problems will be back-ported to the NINA 2 version.  This documentation is for the current NINA 3 version only.

### Image Grading Changes
* Added image grading on FWHM and Eccentricity (requires Hocus Focus plugin).  Note that grading on these metrics is disabled by default so enable via Profile Preferences if desired.
* Added option to move rejected images to a 'rejected' directory
* Added target rotation and ROI to the set of data saved for acquired images.  A future release will use these values when selecting 'like' images for grading.

See updates for [Image Grading](post-acquisition/image-grader.html) and [Profile Preferences](target-management/profiles.html#image-grader).

### Plan Window Stop Time Improvements

Previously, each target plan returned by the scheduler had a stop time determined simply by adding the project's minimum time to the start time (assuming the target doesn't set in that interval).  Now, it will look at the set of upcoming potential targets and see if the stop time can be extended without impact.  The primary benefit is that when plan windows are longer, there is a greater chance that the desired cadence of exposures and dithers will run.  See [Plan Window](concepts/planning-engine.html#plan-window) for details.

This behavior is controlled by a new profile preference: [Smart Plan Window](target-management/profiles.html#general-preferences) which is true by default.  If you want the old behavior, set it to false.

### Synchronization
Added experimental support for [synchronization](synchronization.html) across multiple instances of NINA.  This change is the most impactful of this release to the overall code base but if you're not using synchronization, you should see no change in behavior.

### Other
* Added ability to [purge acquired image records](post-acquisition/acquisition-data.html#purging-records) by date or date/target.
* Added [CSV output](post-acquisition/acquisition-data.html#csv-output) for acquired image records
* The rule weight list is now sorted when displayed.
* Fixed issue where target rotation wasn't being sent to the Framing Wizard.
* You can now delete all exposure plans on a target at once.
* All sequencer instructions moved to new category "Target Scheduler".

Refer to the applicable documentation for details.  See the project [release notes](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/RELEASENOTES.md) and [change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

The plugin is currently in a **_pre-release_** state equivalent to beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.
