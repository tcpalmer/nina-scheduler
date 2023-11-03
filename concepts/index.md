---
layout: default
title: Concepts
nav_order: 3
has_children: true
---

# Concepts

Conceptually, the plugin is divided into three separate areas:
* Project, Target, and Exposure Plan Management
* Runtime execution via the Advanced Sequencer using the _Target Scheduler Container_ instruction
* Post-acquisition activities

## Project and Target Management

The plugin organizes your acquisition data as follows.  Note that all of these entities are unique to a given NINA profile since they often depend on the characteristics of the associated equipment.

### Projects
_Projects_ serve to group a set of _Targets_ and provide common preferences.  Although many projects will have only a single target, it may be useful to group related targets under a single project - for example the separate panels of a mosaic.

### Targets
A _target_ represents a single DSO object with RA/Dec coordinates, frame rotation, and ROI.  Target coordinates can be manually entered or [imported](../target-management/targets.html#target-import) from the NINA catalog, the NINA Framing Assistant, a saved sequence target, or an attached planetarium program (e.g. Cartes du Ciel, Stellarium, etc).  You can also import mosaic panels defined in the Framing Assistant.

### Exposure Plans
Each target has one or more associated _Exposure Plans_ that describe the actual exposures to be taken.  An individual exposure plan sets the exposure length (if you need to override the template default) and the number of exposures desired, as well as referencing an _Exposure Template_ (see below).  Exposure plans also record the number of images for this plan that are deemed acceptable (which can be edited) plus the total number acquired (which can't be changed).  An exposure plan will stay active until the number of accepted images is greater than or equal to the number desired (or the [Exposure Throttle](../target-management/profiles.html#general-preferences) has stopped it).

### Exposure Templates
_Exposure Templates_ provide the ability to set several exposure-related properties that are likely to be common for the associated filter and the rig described by the applicable profile.  Configurable properties include a default exposure time, gain, offset, binning, and camera readout mode.  You can also set the level of twilight and the moon avoidance parameters appropriate for the filter.

Exposure Templates let you decouple most of the properties for an exposure from the Exposure Plan so that they're easy to reuse.  You can also define multiple templates for the same physical filter.

_Note that you must set up an Exposure Template before you can define any Exposure Plans that use it._


See [Project/Target Management](../target-management/index.html) for details.

## Previewing Schedules

Once you have entered a set of projects, targets, and exposure plans, you can preview what the scheduler will do on any given night.  Be aware that the previews are merely representative of what the scheduler will do.  See [Scheduler Preview](../scheduler-preview.html) for notes and caveats.

## Runtime Execution in the Advanced Sequencer

The plugin provides a single primary instruction for the NINA Advanced Sequencer: _Target Scheduler Container_.  The instruction is placed into a Sequential Instruction set.  Triggers can be added to it as needed and should interact with the plugin as expected - for example various autofocus triggers, meridian flip, etc.

A perfectly valid sequence could consist of nothing more than start up instructions (connect equipment, cool camera), the sequential instruction set containing Target Scheduler Container and required triggers, and end instructions (park, warm camera, disconnect).

When the instruction executes, it does the following in a loop:
* Query the _Planning Engine_ for the best target to image at the present time.  If no target is available now but will be later, it will automatically wait for that time before calling the Planning Engine again.
* If the planner returns a target and it is either the first target or different from the previous, it will issue the instructions to slew to the target (and rotate if needed) and then center (plate solve).
* It will then begin executing exposures, switching filters and (optionally) dithering as needed.
* The instruction will also transparently add a trigger to stop acquisition on this target at a specified time.
* When the exposures have completed or the trigger stops execution, the instruction will loop back and call the Planning Engine again.
* If the Planning Engine returns null, the instruction completes.

See the [Advanced Sequencer](../sequencer/index.html) for details.

## Planning Engine

The Planning Engine executes a series of steps to pick the best target to image at the moment and then schedule the applicable exposures for that target.  See [Planning Engine](planning-engine.html) for details.

## Post-acquisition Activities

### Image Grading

In order to increase the level of automation, the plugin includes rudimentary [image grading](../post-acquisition/image-grader.html).  The grader will compare metrics (e.g. HFR and star count) for the current image to a set of immediately preceding images to detect significant deviations.  If the image fails the test, the accepted count on the associated Exposure Plan is not incremented and the scheduler will continue to schedule exposures.  The grader can also grade based on the total RMS guiding error over the exposure duration.

Automatic image grading is inherently problematic and this plugin is not the place to make the final determination on whether an image is acceptable or not.  Towards that end, the plugin will **_never_** delete any of your images.  You are also free to disable Image Grading and manage the accepted count on your Exposure Plans manually - for example after reviewing the images yourself or using more sophisticated (external) analysis methods.

### Image Metadata

The plugin will save [metadata to the database](../post-acquisition/acquisition-data.html) for all images acquired via the plugin.  The records can be viewed in the _View Acquired Image Information_ section of the plugin home page in NINA Plugins.

See [Post-acquisition](../post-acquisition/index.html) for details.































