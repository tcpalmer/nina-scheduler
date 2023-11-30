---
layout: default
title: Target Scheduler Flats
parent: Advanced Sequencer
nav_order: 4
---

# Target Scheduler Flats

Since Target Scheduler saves details on all images captured, it can determine what flats are needed to support calibration of those images.  The **_Target Scheduler Flats_** instruction can be added to your sequences to automatically take those flats.

{: .note }
The current release only supports flats taken with a flat panel device.  Support for sky flats may be added in a future release.

{: .note }
This release supports taking automatic flats based on previously taken lights for any target.  It does not yet support 'immediate' flats taken just after a set of lights when the rotator is still in the exact same position.  This should be coming soon - at least for those with flip-flat style panels so the mount won't have to be slewed to a wall panel.

## Getting Started

### Flat Training
Flats automation depends on finding matching trained flats created using NINA's Flat Wizard.  When training, you _must_ enter the actual gain, offset, and binning you will use in the corresponding light frames.  If you instead rely on the default you've set for the camera, Target Scheduler will not match the trained flats to your acquired light images since it only has image metadata at the point of comparison.  If no matching trained flat is found, the flat set will be skipped.

The **_Target Scheduler Flats_** instruction will also use the 'Flats to take' count in the Flat Wizard as the number of flats to take for all flat sets.

### Project Setup

Flats automation is enabled by setting the Flats Handling [project property](../target-management/projects.html#project-properties).  The values are:
* Off: disable flats automation (default)
* 1, 2, 3, 5, 7, 10, 14: set the cadence to take flats (in days).  This can be thought of as "don't let N days elapse after a light session before taking the corresponding flats".
* Target Completion: only trigger flats on target completion (all Exposure Plans 100% complete)

### Usage in Sequence

You will typically place your **_Target Scheduler Flats_** instruction inside a Sequential Instruction Set to run after your light exposures for the night.  If you need to point your mount to a specific location for flats (e.g. at a wall panel), then you should do so before Target Scheduler Flats.

Once Target Scheduler Flats runs, you might want to include additional instructions to park the mount, open a flip-flap, etc.

## Operation

The instruction works by examining records in the [Acquired Images](../post-acquisition/acquisition-data.html) table for projects/targets that are enabled for flats.  Individual records are aggregated into common _flats specifications_ consisting of:
* A light session date.  This date has a fixed time of noon and is used for all images taken between the upcoming dusk to the following dawn - a _light session_.
* Light exposure parameters: filter, gain, offset, binning, readout mode, rotation, and ROI

The end result is a set of aggregated flats specifications covering all exposures taken over all light sessions.  If the same exposure parameters (filter, gain, etc) are used for multiple targets throughout a night, only one flat specification is needed to capture that.

The set of flat specifications is then compared against the records in the Flats History table.  This table records all flat sets taken with the **_Target Scheduler Flats_** instruction with the corresponding light session date.  If no history record is found that matches a given flats specification, then we potentially need to take those flats.

If the target associated with the corresponding light session is using Target Completion, then the flats are taken immediately.  Otherwise, the current date is compared to the desired cadence and the flats are only taken if more days have elapsed since the light session.

### Examples With Flats Cadence

You set Flats Handling to 1 on the project and then take images over the night of December 1-2.  The Target Scheduler Flats instruction runs the morning of December 2.  Flats will be taken to cover all lights taken over the previous night.

You set Flats Handling to 3 on the project and then take images over the nights of December 1-2, 2-3, and 3-4.  When the Target Scheduler Flats instruction runs the mornings of December 2 and 3, no flats will be taken since not enough time has elapsed.  On the morning of December 4, flats will be taken.

In the previous example, if weather had stopped your sequence early on December 4, and you didn't run again until December 6-7, then on the morning of December 7, flats will be taken to cover the nights of 1-2, 2-3, 3-4, and 6-7.

## Execution

When Target Scheduler Flats runs (and if it determines that flats do need to be taken), it will first prepare the flat device:
* If the device is a flip-flat, it will close the cover.
* It will toggle panel illumination to on.

Then, for each needed flat set:
* Look up the trained flat details from the profile that match the flat specification in filter, gain, offset, and binning.  If none are found, the flat set is skipped.
* If a rotator is connected, set the mechanical angle of the rotator to the value used for the corresponding light frames (which was determined by solve/rotate during acquisition).
* Set the camera readout mode.
* Switch to the applicable filter.
* Set the flat panel brightness to the trained value.
* Take _N_ flat exposures with specified gain, offset, binning, ROI and exposure time (from the trained value), where _N_ is the Flat Wizard 'Flats to take' count.

When all flats have been taken, panel illumination will be toggled off.  If the device is a flip-flat, it will be left in the closed position.

## Notes

### General

* The Target Scheduler Flats instruction will only work with lights acquired via Target Scheduler.
* Images taken with Target Scheduler Flats will use the image file pattern defined for FLAT exposures (Options > Imaging > File Settings).
* For performance reasons, when determining what flats need to be taken, the instruction will only check Acquired Image records newer than 45 days ago.  Even with a flats cadence of 14, you would have a month to take required flats.  If you miss that window, you'll have to take them the old-fashioned way.
* Determination of a light session from Acquired Image records is independent of whether they were accepted or rejected by the grader.
* If you [purge](../post-acquisition/acquisition-data.html#purging-records) Acquired Image records, you may impact flats determination.
* If you set Flats Handling to something other than Off for a target with existing activity and then run Target Scheduler Flats, it will produce flat sets covering all previous light sessions going back 45 days ... which may be substantial.
* If you delete a project or target, any associated flats history records will also be deleted.
* Even though camera readout mode and ROI are not part of flats training in the Flat Wizard, the values that applied during acquisition will be honored when taking the corresponding flats.

### Profiles
* When you run Target Scheduler Flats, it will only operate on targets and acquired images associated with the NINA profile currently in use.
* You will need to train flats in the Flat Wizard on all profiles for which you want to automate flats. 
* Since the NINA profile is different on a [synchronized client](../synchronization.html), you would have to run Target Scheduler Flats in your client sequence as well as your server sequence.

### Rotation

* If you're using a rotator, be aware that the rotation angle used will be the **_mechanical rotator angle_** as determined by NINA during solve/rotate.  This may well be different from the rotation angle originally set for the target but since it's the value that was used for the corresponding light exposures, it applies to the flats as well.  The mechanical angle is the value saved in the _ROTATOR_ and _ROTATANG_ FITS header elements.
* Taking flats with rotation after the rotator has been moved may be problematic depending on the rotational tolerance you set for solve/rotate and the quality of your rotator.  If you're having difficulty calibrating with rotated flats, you may need to decrease the tolerance, invest in a better rotator, or take flats some other way.
