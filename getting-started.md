---
layout: default
title: Getting Started
nav_order: 5
---

# Getting Started

The Target Scheduler is more complex than the average NINA plugin.  Successful use requires that you understand the plugin [concepts](concepts/index.html) and ensure that you have met the prerequisites listed below.

{: .note }
Before you ask for help, please be sure you have met the following prerequisites and made an effort to understand how the plugin operates.

## Prerequisites
* You should be reasonably adept at using the NINA Advanced Sequencer, understanding the concepts behind instructions, sequence containers, and triggers.  If you are new to NINA, it would be best to spend time getting to know the software and how it interacts with your equipment.
* Although the plugin is designed primarily for DSO imagers using monochrome astrophotography cameras with a filter wheel, you can [configure it for color cameras](target-management/exposure-templates.html#color-cameras), perhaps using a fixed filter tray.
* You should already have NINA configured with at least one profile describing your location, camera, filter wheel, etc.
* Your filter wheel configuration should be stable.  If you later change the filter names (even 'L' to 'Lum') you might encounter issues with old references to 'L'.
* **_You should be able to successfully run sessions via the Advanced Sequencer with this profile.  The inevitable glitches with new equipment should have been worked out._**
* Sky conditions notwithstanding, your sequences should be able to reliably plate solve and execute meridian flips without intervention.
* You are familiar with the plugin's [concepts](concepts/index.html).

## First Steps
These steps assume you have already installed the plugin via the NINA Plugins page.

There are two main points of interaction with the plugin's capabilities.
* The plugin home page (in the NINA Plugins tab) provides the UI to manage the [Project / Target Database](target-management/index.html), [preview schedules](scheduler-preview.html), see target [acquisition reports](post-acquisition/reporting.html), and view detailed metadata on [acquired images](post-acquisition/index.html).
* The plugin adds a single new instruction named **_Target Scheduler Container_** that you will add to your sequence.  See the [Advanced Sequencer](sequencer/index.html) for details.

The sections below will walk you through creation of your first project, target, and exposure plan.

### Create a Project

1. Open the plugin home page at NINA Plugins > Target Scheduler.
2. Expand the Target Management section. 
3. Expand 'Profiles' in the Projects navigation tree on the left.
4. Select (click) the profile that your new project should be associated with.  This profile should also be the currently active NINA profile (NINA Options > Profiles).
5. Click the Add Project icon on the right.
6. Click the Edit icon to make changes:
  * Enter an appropriate name and an (optional) description.
  * Set the State to Active.  In many cases, you'll leave a new project in Draft state until you get it finalized but we'll preview this below and it has to be active for that to work.
  * Review the other Project properties but the defaults are fine for now.
7. Click the Save icon to save your changes.

See [Projects](target-management/projects.html) for details on all properties.  After saving, your new project will appear in the Projects nav tree under the profile.

### Create a Target

1. With your new project still selected in the Projects nav tree, click the Add Target icon on the right.
2. Click the Edit icon to make changes:
  * You can enter target coordinates manually or import from another source.
To import, click the Import Coordinates icon and then use one of the four methods to import.  For this example, just enter 'M 31' in the NINA Catalog field and click it.  That should import the coordinates and set the name.
  * Review the other Target properties but the defaults are fine for now.
3. Click the Save icon to save your changes.  We'll return to this target and add Exposure Plans after adding an Exposure Template.

See [Targets](target-management/targets.html) for details on all properties.  After saving, your new target will appear in the Projects nav tree under the new project you created above.

### Create an Exposure Template

A Target has one or more Exposure Plans to specify the actual exposures you want to take.  However, each Exposure Plan references an _Exposure Template_ which names the actual filter to use as well as several other properties.  Exposure Templates serve to decouple commonly used properties from Exposure Plans.

1. In the Exposure Templates nav tree on the lower left, expand 'Profiles' and select the same NINA profile you used for the project you created above.
2. Click the Add Exposure Template icon on the right.
3. Click the Edit icon to make changes:
  * Enter a name for the template.  It usually makes sense to include the filter name in the template name, for example, 'Lum Default'.
  * Select the desired filter from the dropdown.  The filter name options are loaded from the filter wheel configuration for this NINA profile (NINA Options > Equipment > Filter Wheel).
  * Set a default exposure duration.  This will be used unless overridden in Exposure Plans that use this template.
  * Review the other properties but the defaults are fine for now.

See [Exposure Templates](target-management/exposure-templates.html) for details on all properties.  After saving, your new template will appear in the Exposure Templates nav tree under the profile.


### Add an Exposure Plan to Your Target

Now that you've created an Exposure Template, you can create an Exposure Plan that will reference it.

1. In the Projects nav tree, select the Target you created above, for example 'M 31'.
2. Click the Edit icon.
3. Click the Add Exposure Plan icon.
  * An exposure plan will be added and will default to using the first Exposure Template for this profile (which is the one you just created).  When you have more templates, you can select the one you want in the Template dropdown.
  * Leave the Exposure field blank - it will use the default from the template. 
  * Change the Desired field to the number of exposures needed for this plan. 
  * Do not change the Accepted value (discussed elsewhere).
4. Click the Save icon to save your changes.

See [Exposure Plans](target-management/exposure-plans.html) for details on all properties.  After saving, your new exposure plan will appear under the Target properties.

### Run a Preview

To confirm that your new project and target are ready for preview and scheduling, select your new project in the Projects nav tree.  You should see the green checkmark after the project name in the panel title.  Select your new target and should see the same green checkmark after the target name in the panel title.  If you see the red indicator instead, then there is some condition that is blocking scheduling (see [Active/Enabled](target-management/index.html#activeenabled) for more information).

1. Close the database management UI by clicking 'Target Management' above the Projects nav tree.
2. Click 'Scheduler Preview' to open the preview panel.
3. Click the Run button to generate a preview of what the scheduler would do when starting at the specified date/time.

M31 was chosen above because it's visible for much of the year from most latitudes.  However, if nothing is returned by the previewer, you probably need to enter different target coordinates for something visible tonight from your location.  You may have to change the Date/Time or Profile fields as well and rerun.

The panel below the Run button will show the steps that the scheduler generated for the selected date/time and profile.  Click each project/target line (probably just one at this point) to expand it and show all instructions for that target.  See [Scheduler Preview](scheduler-preview.html) for more information.

{: .note }
If you examine the instructions and something doesn't look right, please read the differences between a preview and a real run in the sequencer.  You can also click the 'View Details' button to see details on why the planner made the decisions it did.

### Create a Sequence

Once you have created one or more projects and targets and are ready to image, you'll need to create a sequence for the NINA Advanced Sequencer that uses the Target Scheduler Container instruction.  See [Advanced Sequencer](sequencer/index.html) for more information.
