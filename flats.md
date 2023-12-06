---
layout: default
title: Flat Frames
nav_order: 9
has_children: false
---

# Target Scheduler Flats

Since Target Scheduler saves details on all images captured, it can determine what flats are needed to support calibration of those images.  The **_Target Scheduler Flats_** and **_Target Scheduler Immediate Flats_** instructions can be added to your sequences to automatically take those flats.

{: .note }
The current release only supports flats taken with a flat panel device.  Support for sky flats may be added in a future release.

## Getting Started

It takes three steps to begin running automated flats with Target Scheduler:
* Train flats in the NINA Flat Wizard
* Setup your projects for flats handling
* Add the appropriate instruction to your sequence

### Flat Training
Flats automation depends on finding matching trained flats created using NINA's Flat Wizard.  When training, you typically want to be as specific as possible in terms of gain, offset, and binning to exactly match your corresponding light frames.  However, if no exact match is found, it will also try (in order):
* Missing/default gain
* Missing/default offset
* Missing/default gain and offset

If no trained flat was found, the flat set will be skipped.

Once your flats are trained, you can review them in Equipment > Flat Panel.  You should see a table with all trained values - be sure they make sense for the lights you plan to acquire.

The flats instructions will also use the 'Flats to take' count in the Flat Wizard as the number of flats to take for all flat sets.

### Project Setup

Flats automation is enabled by setting the Flats Handling [project property](../target-management/projects.html#project-properties).  The values are:
* **Off**: disable flats automation (default)
* 1, 2, 3, 5, 7, 10, 14: set the cadence to take flats (in days).  This can be thought of as "don't let N days elapse after a light session before taking the corresponding flats".
* **Target Completion**: only trigger flats on target completion (all Exposure Plans 100% complete)
* **Use With Immediate**: enable flats but only for use with the Target Scheduler Immediate Flats instruction.


## Usage in Sequence

Deciding which flats instruction to use mostly depends on whether you have a rotator or not:
* If you do have a rotator, you can increase the rotational accuracy of flats by using the **_Target Scheduler Immediate Flats_** instruction - but at the expense of taking dark sky time away from lights.
* If you don't have a rotator, then it's almost certainly better to use **_Target Scheduler Flats_**.

### Target Scheduler Flats

You will typically place your **_Target Scheduler Flats_** instruction inside a Sequential Instruction Set to run after your light exposures for the night - for example at nautical dawn.  If you need to point your mount to a specific location for flats (e.g. at a wall panel), then you should do so before Target Scheduler Flats.

The instruction works as follows:
* Determine the flats that need to be taken (see [Operation](#operation) below).  The search will be over all active projects/targets with Flats Handling set to one of the cadence values or **_Target Completion_**.
* If the flat device is a flip-flat, close the cover
* Toggle the panel to on.
* For each flat set:
  * Look up the trained flat settings that match the corresponding light exposures (filter/gain/offset/binning).
  * Set the rotator mechanical position (only if a rotator is connected)
  * Switch filter
  * Set the panel brightness to the trained value
  * Take _N_ flat exposures with specified gain, offset, binning, ROI and exposure time (from the trained value), where _N_ is the Flat Wizard 'Flats to take' count.
* Toggle the panel to off.

Note that a flip-flat will be left in the closed position - add an instruction to reopen it if needed.

### Target Scheduler Immediate Flats

This instruction _**must**_ be placed into the _After Each Target_ custom event container of Target Scheduler.  Otherwise it will not work since it needs access to the current plan target and assumes that the rotator doesn't need to be moved from the position set via the previous slew, center, and rotate.

If your flat device is a flip-flat, then your instructions in _After Each Target_ might be:
* Target Scheduler Immediate Flats
* Open Flat Panel Cover

If you have a wall panel, it's a bit more complex:
* Slew To Alt/Az
* Set Tracking Stopped
* Target Scheduler Immediate Flats
* Slew and center

The first alt/az slew should position the scope to point at your wall panel.  The final slew will slew the mount back to the target coordinates and plate solve.  You could run a Slew, Center, and Rotate here, but you probably want to leave the rotator where it is in case the same target is returned next by the planner.

Immediate flats differ from flats taken with Target Scheduler Flats in two ways:
* It will only generate flats for the current target _and_ that target has project Flats Handling set to **_Use With Immediate_**.  Since it runs within the _After Each Target_ custom event container of Target Scheduler, it has access to the current target and planned exposures.
* It assumes that the rotator is still in the same position set via the previous slew, center, and rotate performed just before the lights - so there's no need to move it.

Other than the skipped rotation, it performs the same steps as **_Target Scheduler Flats_**.

### Repeat Flat Sets

Both flats instructions have a _**Repeat Flat Sets**_ option which defaults to OFF.  If ON, it means that flat sets will be repeated even if they're duplicates of another set.  The implementation is slightly different for each instruction:

#### Target Scheduler Flats

When flats are required, the full set may contain many duplicates - either the same target/filter over multiple nights or a different target using the same filter (i.e. Exposure Template).  If Repeat Flat Sets is OFF, these duplicates will be skipped.  However, there is a reason you might want to take the time to repeat them.  If you don't, then any usage of the \$\$TARGETNAME\$\$ or \$\$TSSESSIONID\$\$ image file patterns (see below) will only reflect the first instance of duplicates since that's the only set actually taken and saved to disk.

#### Target Scheduler Immediate Flats

If the same target is returned by the planner multiple times in a night, you could generate repeated flat sets for each filter in use by that target.  By default, with the option OFF, it means that it will not repeat them when running during the same night.  Regardless, it will ignore any flats taken for that target on previous nights when determining repeats.

However, if rotator repeatability is an issue for you, then you might want to set this to ON so that you'll regenerate flats for each plan (which means separately for each set of lights captured after each solve/rotate).  This will obviously take more time away from imaging lights.

## Session Identifier for Lights and Flats

The flats capability introduces the concept of a Target Scheduler _session identifier_ that can link flats to the associated lights.  The value is made available by a custom Image Pattern named \$\$TSSESSIONID\$\$.  The pattern can be used in your image file patterns (Options > Imaging) just like \$\$FILTER\$\$ or \$\$TARGETNAME\$\$.  The value is just a number in a fixed-width string like '0001' or '0023'.

When used in a file pattern, you would typically prefix it with something like 'SESSION_'.  So a file pattern of:

```
$$TARGETNAME$$\$$DATEMINUS12$$\$$IMAGETYPE$$\$$FILTER$$\SESSION_$$TSSESSIONID$$\etc
```

Might yield:

```
M31\2023-12-01\LIGHT\Lum\SESSION_0023\etc
M31\2023-12-07\FLAT\Lum\SESSION_0023\etc
```

The value is available in \$\$TSSESSIONID\$\$ when both lights and flats are taken by Target Scheduler.  It's also saved to all Acquired Image records to permit determination of light/flat correspondence when the flats instructions are executed.

The main use case for this is to permit grouping of lights and flats for use in post-processors like PixInsight's WBPP.

### Calculation

The value of the session identifier is tied to the Flats Handling setting on the associated Project and is most useful when the value is set to one of the cadence values (1, 2, 3, 5, 7, 10, 14).  It's equal to the number of days since project creation divided by the cadence, plus 1.

For example, if the project was created on June 1, 2023, Flats Handling is 7, and the current date is December 5, 2023, then the value would be '0027'.  If instead Flats Handling was 3, the value would be '0063'.

If Flats Handling on the Project is set to _Off_, _Target Completion_, or _Use With Immediate_, then the calculated value is the same as for a cadence of 1.

Be aware that if you change the Flats Handling value after you've been operating for some time, you could potentially skip or duplicate future identifiers.

## Notes

### Profiles
* When you run either flats instruction, it will only operate on targets and acquired images associated with the NINA profile currently in use.
* You will need to train flats in the Flat Wizard on all profiles for which you want to automate flats.
* Since the NINA profile is different on a [synchronized client](../synchronization.html), you would have to run Target Scheduler Flats in your client sequence as well as your server sequence.  At present, it would not be possible to run Target Scheduler Immediate Flats on clients since that must run in the _After Each Target_ container ... which only runs on the server.

### Rotation

* If you're using a rotator, be aware that the rotation angle used will be the **_mechanical rotator angle_** as determined by NINA during solve/rotate.  This may well be different from the rotation angle originally set for the target but since it's the value that was used for the corresponding light exposures, it applies to the flats as well.  The mechanical angle is the value saved in the _ROTATOR_ and _ROTATANG_ FITS header elements.
* The mechanical angle for all light images is saved so it can be subsequently used for flats corresponding to those lights.  If the rotator was moved since those lights were taken, it will be moved back to the position at which the lights were taken.  However, you may have difficulty calibrating with those flats - especially if your rotator has backlash or other problems duplicating a previous position.  In this case, you can decrease the rotational tolerance (NINA Options > Plate Solving), invest in a better rotator, or use the Target Scheduler Immediate Flats instruction as discussed above.

## Operation

The instruction works by examining records in the [Acquired Images](../post-acquisition/acquisition-data.html) table for projects/targets that are enabled for flats.  Individual records are aggregated into common _flats specifications_ consisting of:
* A light session date.  This date has a fixed time of noon and is used for all images taken between the upcoming dusk to the following dawn - a _light session_.
* The session identifier
* Light exposure parameters: filter, gain, offset, binning, readout mode, rotation, and ROI

The end result is a set of aggregated flats specifications covering all exposures taken over all light sessions.  If the same exposure parameters (filter, gain, etc) are used for multiple targets throughout a night, only one flat specification is needed to capture that.

The set of flat specifications is then compared against the records in the Flats History table.  This table records all flat sets taken with the **_Target Scheduler Flats_** and **_Target Scheduler Immediate Flats_** instruction with the corresponding light session date.  If no history record is found that matches a given flats specification, then we potentially need to take those flats.

If the target associated with the corresponding light session is using _Target Completion_, then the flats are taken immediately.  Otherwise, the current date is compared to the desired cadence and the flats are only taken if more days have elapsed since the light session.

### Examples With Flats Cadence

You set Flats Handling to 1 on the project and then take images over the night of December 1-2.  The Target Scheduler Flats instruction runs the morning of December 2.  Flats will be taken to cover all lights taken over the previous night.

You set Flats Handling to 3 on the project and then take images over the nights of December 1-2, 2-3, and 3-4.  When the Target Scheduler Flats instruction runs the mornings of December 2 and 3, no flats will be taken since not enough time has elapsed.  On the morning of December 4, flats will be taken.

In the previous example, if weather had stopped your sequence early on December 4, and you didn't run again until December 6-7, then on the morning of December 7, flats will be taken to cover the nights of 1-2, 2-3, 3-4, and 6-7.

## Other Notes

* The Target Scheduler Flats instruction will only work with lights acquired via Target Scheduler.
* Images taken with either flats instruction will use either the default image file pattern or the specific one defined for FLAT exposures (Options > Imaging > File Settings).
* For performance reasons, when determining what flats need to be taken, the instruction will only check Acquired Image records newer than 45 days ago.  Even with a flats cadence of 14, you would have a month to take required flats.  If you miss that window, you'll have to take them the old-fashioned way.
* Determination of a light session from Acquired Image records is independent of whether they were accepted or rejected by the grader.
* If you [purge](../post-acquisition/acquisition-data.html#purging-records) Acquired Image records younger than 45 days and the associated target is still active, you will impact flats determination.
* If you set Flats Handling to something other than Off for a target with existing activity and then run Target Scheduler Flats, it will produce flat sets covering all previous light sessions going back 45 days ... which may be substantial.
* If you delete a project or target, any associated flats history records will also be deleted.
* Even though camera readout mode and ROI are not part of flats training in the Flat Wizard, the values that applied during acquisition will be honored when taking the corresponding flats.

