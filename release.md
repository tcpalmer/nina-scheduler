---
layout: default
title: Release Notes
nav_order: 13
---

# Release Notes 4.3.1.0
_Released February 2, 2024_

## Changes in this Release

This release is available for NINA 3.  Only fixes for serious problems will be back-ported to the NINA 2 version.  This documentation is for the current NINA 3 version only.

* Another tweak to TS Condition to ensure loop remains completed
* Fixed bug where target from Framing Wizard would appear to replace target in TS target management panel
* Code clean up

See below for details on [previous releases](#previous-releases).

## General

Refer to the applicable documentation for details.  See the project [release notes](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/RELEASENOTES.md) and [change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

## Known Issues

* If image grading is off, the completion percentage on exposure plans is not calculated properly (i.e. based on the exposure throttle).  Also, the green/red active/inactive icons (which depend on the completeness calculation) will not be correct.
* Icons disappear when using Light or Seance color schemes.
* Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
* Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.

## Previous Releases

### Target Scheduler 4.3.0.0
_Released January 26, 2024_
* Fixed issue where TS Condition wasn't working when called in outer containers
* Increased timeout for sync client registration
* Added validation of TS Container triggers and custom event containers
* Stopped cloning of TS Container triggers into plan sub-container (now run normally)
* Added additional logging of sequence item lifecycle events

### Target Scheduler 4.2.0.0
_Released December 28, 2023_
* Added ability to [bulk load targets](target-management/targets.html#bulk-target-import) from CSV files.

### Target Scheduler 4.1.2.2
_Released December 21, 2023_
* Fixed bug in readout mode handling
* Fixed bug with Percent Complete and Mosaic Complete scoring rules if image grading is off

### Target Scheduler 4.1.2.0
_Released December 18, 2023_
* Fixed bug in smart plan window - was skipping projects incorrectly
* Fixed another bug with determining target completed
* You can now choose to delete acquired image records (not image files) when deleting the associated target.  See the _Delete Acquired Images_ [preference](target-management/profiles.html#profile-preferences) (enabled by default).
* If running as a [sync client](synchronization.html), TS Condition will now use the server's data for the targets remain or projects remain checks

### Target Scheduler 4.1.1.3
_Released December 15, 2023_
* Fixed bug in TS Flats: if your project flats cadence is greater than 1, then it wasn't properly accounting for flats for the same filter already taken - you'd basically take too many.
* Fixed bug with determining target completeness when image grading is off and exposure throttling applies.
* Fixed missing TS version in TS log.

### Target Scheduler 4.1.1.1
_Released December 14, 2023_
* Fixed bug in TS Condition - check wasn't running the first time through 
* Immediate flats wasn't handling Repeat Flat Set off correctly 
* Immediate flats instruction will now open a flip-flat cover when done 
* Updated for latest NINA 3 beta libraries

### Target Scheduler 4.1.0.8
_Released December 12, 2023_
* Added support for taking automated flats
* Optimized the condition check in Target Scheduler condition 
* Target Scheduler Container instruction has a new custom event container: After Each Target 
* Added a 'need flats' check to Target Scheduler condition

### Target Scheduler 4.0.5.1
_Released November 26, 2023_
* Improved handling when TS is canceled/interrupted which means it behaves better in safety scenarios and with Powerups safety controls.  Be sure you are running Powerups 3.10.10.1 or later.  Thanks to @Marc  for his changes and consultation.

### Target Scheduler 4.0.5.0
_Released November 17, 2023_
* Added image grading on FWHM and Eccentricity (requires Hocus Focus plugin)
* Added option to move rejected images to a 'rejected' directory 
* Added ability to purge acquired image records by date or date/target 
* Added CSV output for acquired image records 
* Added better support for the Center After Drift trigger (see release notes)
* Added smarter determination of plan stop times 
* Added ability to delete all target exposure plans 
* The rule weight list is now sorted when displayed 
* Added target rotation and ROI to the set of data saved for acquired images.  A future release will use these values when selecting 'like' images for grading. 
* Fixed issue where target rotation wasn't being sent to Framing Wizard 
* Added experimental support for synchronization across multiple instances of NINA 
* All sequencer instructions moved to new category "Target Scheduler"

### Target Scheduler 3.3.3.1
_Released October 11, 2023_
* Fixed bug with exposure planner.

### Target Scheduler 3.3.3.0
_Released September 19, 2023_
* Fixed edge case bug with custom horizons.

### Target Scheduler 3.3.2.0
_Released September 7, 2023_
* Fixed problem with override exposure ordering. Unfortunately, any existing override order had to be cleared (automatically) for this fix.  You'll have to manually redo any that you had already created.

### Target Scheduler 3.3.1.0
_Released August 22, 2023_
* Added ability to override exposure ordering 
* Added Mosaic Completion scoring rule 
* Fixed bug with rotation not being set when importing from a saved Sequence Target 
* Fixed bug related to non-existent custom horizon

### Target Scheduler 3.2.1.0
_Released August 9, 2023_
* Fixed bug preventing target ROI from being applied properly.  If you're not using ROI, you wouldn't be impacted.

### Target Scheduler 3.2.0.0
_Released August 7, 2023_
* Added ability to copy/paste exposure plans. 
* Added fixed date range options to Acquired Images viewer and improved performance. 
* Added ability to select images in the Acquired Images table by filter used. 
* Fixed issue with scheduler preview: wasn't picking up dynamic changes to target database. 
* Added 5/10/20 minute options to project minimum time. 
* Will automatically unpark the scope if parked before a target slew. 
* Fixed the annoying bug related to editing Exposure Templates on Target Exposure Plans. 
* Images in the acquired images table will now show 'not graded' as the Reject Reason if grading was disabled when the image completed. 
* Now skips useless Target Scheduler Condition checks.

### Target Scheduler 3.1.2.0
_Released July 20, 2023_
* This release is for NINA 3 only.  All previous releases (0.8.0.0 and earlier) were for NINA 2.  From this point forward, only fixes for serious problems will be back-ported to the NINA 2 version.  The online documentation is now for NINA 3 only.
* You can now add custom instructions at various points in the lifecycle of the planner.  Four separate instruction containers are provided to add your instructions: before or after a wait period and before or after execution of a new/changed target.  For example, you could park your mount and/or close a flip-flat before a wait and then reverse after the wait.
* The display of running instructions in the Target Scheduler Container instruction has been greatly improved.
* Scheduler Preview now provides a 'View Details' button to display details about the planning and decision-making process.  The same information is also written to the Target Scheduler log for actual runs via the sequencer.
