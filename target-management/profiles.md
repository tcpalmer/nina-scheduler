---
layout: default
title: Profiles
parent: Project / Target Management
nav_order: 1
---

# Profiles
Each NINA profile is represented with a (possibly empty) folder in the navigation trees.  Your projects, targets, etc are explicitly associated with a single NINA profile since the associated settings will likely depend on the equipment defined for that profile.

If you delete a profile that had Target Scheduler entities assigned to it, they are not lost, but they are [orphaned](index.html#orphaned-items).

## Profile Preferences
A set of preferences can be managed for each profile and will impact execution of all projects and targets associated with that profile.

### General Preferences

|Property|Type|Default|Description|
|:--|:--|:--|:--|
|Park On Wait|bool|false|Normally, when the planner returns a directive to wait a period of time for the next target, the plugin will simply stop tracking and guiding.  If this setting is true (and the wait is more than one minute), the mount will also be parked and then unparked when the wait is over.  If you instead use the [Before Wait/After Wait](../sequencer/index.html#custom-event-instructions) custom containers to park and unpark, you should leave this set to false.|
|Exposure Throttle|int|125%|When Image Grading is disabled (at the Project level) and the Accepted count on Exposure Plans isn't incremented manually, the planner will keep scheduling exposures - perhaps way beyond what is reasonable.  The Exposure Throttle will instead use the total number Acquired (displayed with Desired and Accepted) to stop exposures when the number Acquired is greater than Exposure Throttle times the number Desired.  For example, if Exposure Throttle is 150%, Desired=10, and Acquired=5 then an additional 10 exposures will be scheduled.  This has no effect if Image Grading is enabled.|
|Smart Plan Window|bool|true|If enabled, examine future potential targets to better determine the [stop time](../concepts/planning-engine.html#plan-window) for the selected target.  Otherwise, use the legacy method based only on the target's minimum imaging time and/or meridian window.|
|Delete Acquired Images|bool|true|If enabled, whenever a target is deleted, any [Acquired Image](../post-acquisition/acquisition-data.html) records associated with that target will also be deleted.  This also applies to targets deleted when the parent project is deleted.  In general, you should leave this enabled since deleting targets but leaving the acquired image records may lead to confusion since database IDs can be reused.  No actual image files will ever be deleted.|


### Image Grader
The following preferences drive the behavior of the [Image Grader](../post-acquisition/image-grader.html).  Since projects have grading enabled by default and all types of grading (below) are also enabled by default, your images will be graded unless you take steps to disable it.  The defaults were selected to be relatively permissive.

|Property|Type|Default|Description|
|:--|:--|:--|:--|
|Max Samples|int|10|The maximum number of recent images to use for sample determination|
|Grade RMS|bool|true|Enable grading based on the total RMS guiding error during the exposure|
|RMS Pixel Threshold|double|8|The threshold to accept/reject based on guiding RMS error|
|Grade Detected Stars|bool|true|Enable grading for the number of detected stars|
|Detected Stars Sigma Factor|double|4|The number of standard deviations surrounding the mean for acceptable star count values|
|Grade HFR|bool|true|Enable grading based on calculated image HFR|
|HFR Sigma Factor|double|4|The number of standard deviations surrounding the mean for acceptable values of HFR|
|Grade FWHM|bool|false|Enable grading based on calculated image Full Width Half Maximum.  The Hocus Focus plugin must be installed, enabled, and set up for Star Detection (Fit PSF ON).  Be sure you have enabled Hocus Focus in Options > Imaging > Image options.|
|FWHM Sigma Factor|double|4|The number of standard deviations surrounding the mean for acceptable values of FWHM|
|Grade Eccentricity|bool|false|Enable grading based on calculated image Eccentricity.  The Hocus Focus plugin must be installed, enabled, and set up for Star Detection (Fit PSF ON).  Be sure you have enabled Hocus Focus in Options > Imaging > Image options.|
|Eccentricity Sigma Factor|double|4|The number of standard deviations surrounding the mean for acceptable values of FWHM|
|Accept All Improvements|bool|true|Grading on star count, HFR, FWHM, and Eccentricity will be biased based on the samples used for comparison.  If they are sub-optimal in some way (bad seeing, passing cloud) then subsequent images with significant improvements may be rejected for falling outside the standard deviation range - and the set of comparison samples will not improve.  If this setting is true, then a new image with a sample value greater than (for star count) or less than (for HFR, FWHM, Eccentricity) the mean of the comparison samples will be automatically accepted.|
|Move Rejected Images|bool|false|If enabled and a graded image was rejected, it will be moved to a 'rejected' folder under the image save folder.  See note below.|

#### Move Rejected Images
* Moving images may have undesirable impacts to other code (including plugins) that expects to find images in a specific location.  Potential plugin impacts:
  * Remote Copy.  In general, the source directory for Robocopy is above the actual save location in the folder hierarchy so it should work but you should verify.
  * Web Session History Viewer.  Although the image thumbnails will continue to work, clicking an image to see the source image will not since it was moved from the expected location.  This may be addressed in a future release of the Web plugin.
* If you're using [synchronization](../synchronization.html) and want to enable this, be sure to enable it in the profile preferences for both the server and client profiles.

### Synchronization Preferences
The following preferences control [synchronization](../synchronization.html).

| Property                |Type|Default| Description                                                                                                                                                                                                                                                        |
|:------------------------|:--|:--|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Enable Synchronization  |bool|false| Enable synchronization for this profile.                                                                                                                                                                                                                           |
| Wait Timeout            |int|300| The timeout (in seconds) used by the [Target Scheduler Sync Wait](../synchronization.html#target-scheduler-sync-wait) instruction on both sync server and client instances.                                                                                        |
| Action Timeout          |int|300| The timeout (in seconds) used by the server when waiting for all clients to accept an _action_: an exposure, a solve/rotate command, or a custom event container.  See [Target Scheduler Sync Container](../synchronization.html#target-scheduler-sync-container). |
| Solve/Rotate Timeout    |int|300| The timeout (in seconds) used by the server when waiting for all clients to complete a solve/rotate command.  See [Slew/Center/Rotate](../synchronization.html#slewcenterrotate).                                                                                  |
| Event Container Timeout |int|300| The timeout (in seconds) used by the server when waiting for all clients to complete a custom event container.  See [Target Scheduler Sync Container](../synchronization.html#target-scheduler-sync-container).                                                                                                                                              |
