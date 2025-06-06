---
layout: default
title: Projects
parent: Project / Target Management
nav_order: 2
---

# Projects
Projects are the main organizing entity for the plugin.  Each project belongs to a single NINA profile.  Each target is associated with a single project.  Multiple targets can be added to a project and will share the project's properties.  Targets for a project are expected (but not required) to be the same area of the sky since the chief motivation for this approach is mosaics.  For additional thoughts on how to organize your projects and targets, see [Project/Target Organization](organization.html).

## Basic Operations

### Project Creation

New projects are added by selecting the applicable profile in the Projects navigation tree and then clicking the Add icon.  The new project is saved, added to the navigation tree, and selected.  Click the Edit icon to make changes.

When you select a profile in the Projects navigation tree, the right panel shows a table of all projects for that profile.  A green checkmark indicates that the project will be considered for scheduling (it's active and the project has at least one active Target with at least one exposure plan that needs exposures).  You can also jump to the view/edit panel for the project (<img src="../assets/images/settings-icon.png" width="18" height="18">) or copy it to the clipboard (<img src="../assets/images/copy-icon.png" width="18" height="18">).  After copying a project, you can paste it under this profile or select a different profile in the tree and paste it there.

### Project Editing

Click the Edit icon to begin editing the project.  The property value fields become active and you can make changes.  Note that you typically have to tab out after editing to enable the Save icon.

When done, click the Save icon to save your changes or the Cancel icon to cancel.

### Project Deleting

Click the Delete icon to delete a project and all associated targets.  If the _Delete Acquired Images_ [preference](profiles.html#profile-preferences) (enabled by default) is on, then any [acquired image](../post-acquisition/acquisition-data.html) records (not image files) associated with those targets will also be deleted.

### Mosaic Panel Import
If you used the NINA Framing Assistant to create mosaic panels for a target, you can import them all as new Targets under the project.  First, configure your panels in the Framing Assistant.  Then return to the plugin management UI and view the desired project and click the Mosaic Import icon to begin.  If the icon isn't enabled, you may have to select something else in the navigation tree and then return to the project.

When you import mosaic panels into a project, the Mosaic Project flag is automatically set to true.

### Reset Completion

You can reset completion for an entire project.  This will set the Accepted and Acquired fields to zero on all Exposure Plans for all Targets under this project.  Associated [acquired images](../post-acquisition/acquisition-data.html) are not removed.

### Project Properties

| Property                 | Type          | Description                                                                                                                                                                                                                                                               |
|:-------------------------|:--------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Name                     | string        | The name of the project.                                                                                                                                                                                                                                                  |
| Description              | string        | An optional description.                                                                                                                                                                                                                                                  |
| State                    | dropdown      | Current state of the project: Draft, Active, Inactive, Closed (see below).                                                                                                                                                                                                |
| Priority                 | dropdown      | Project priority for the Scoring Engine: Low, Normal, High.                                                                                                                                                                                                               |
| Minimum Time             | minutes       | The minimum imaging time that a project target must be visible to be considered.  See below for interaction with Meridian Window.                                                                                                                                         |
| Minimum Altitude         | double        | The minimum altitude for project targets to be considered.  See below for details on horizon determination.                                                                                                                                                               |
| Maximum Altitude         | double        | The maximum altitude for project targets to be considered.  See below for details on horizon determination.                                                                                                                                                               |
| Use Custom Horizon       | boolean       | Use the custom horizon defined for the associated profile (NINA Options > General > Astrometry).  See below for details on horizon determination.                                                                                                                         |
| Horizon Offset           | double        | A value to add to the custom horizon to set the minimum altitude at the target's current azimuth.  Disabled if Use Custom Horizon is disabled.  See below for details on horizon determination.                                                                           |
| Meridian Window          | minutes       | Limit imaging to a timespan in minutes around the meridian crossing.  A setting of 60 implies 1 hour on either side of the meridian or 2 hours total.  See below for potential interactions and conflicts.  Set to zero to disable.                                       |
| Filter Switch Frequency  | integer 0-N   | Value to determine how exposures for different filters are scheduled.  See below for details.                                                                                                                                                                             |
| Dither After Every       | integer 0-N   | Value to determine how dithering is handled.  See below for details.                                                                                                                                                                                                      |
| Smart Exposure Selection | boolean       | Enable/disable exposure selection based on moon avoidance criteria.  See below for details.                                                                                                                                                                               |
| Enable Image Grader      | boolean       | Enable/disable the [Image Grader](../post-acquisition/image-grader.html).                                                                                                                                                                                                 |
| Mosaic Project           | boolean       | Mark the project as containing mosaic panels.  This defaults to false.  It can be changed manually but will automatically be set to true if you import panels from the Framing Assistant.  At present, the only logic this impacts is the Mosaic Completion scoring rule. |
| Flats Handling           | integer       | Specify behavior for [automated flats](../sequencer/flats.html).                                                                                                                                                                                                          |
| Rule Weights             | integer 0-100 | Weight values for each Scoring Engine rule - see below.                                                                                                                                                                                                                   |

#### Project Name
If Target Scheduler is actively taking images for a managed target (lights or flats), the name of the associated project is available in the custom image file pattern \$\$TSPROJECTNAME\$\$.  The pattern can be used in your image file patterns (Options > Imaging) just like \$\$FILTER\$\$ or \$\$TARGETNAME\$\$.

#### Project State

The project state provides control over whether a project is considered for scheduling or not - and only Active projects are considered.  When a project is first created, the state is Draft; complete project/target setup and then set the state to Active.  Use the Inactive and Closed states as needed.

#### Meridian Window Interactions/Conflicts
If a project specifies a meridian window, then the minimum time cannot be greater than twice the meridian window value.  If it was, then targets for that project would never be selected since the total meridian window would always be less than the minimum time.

If you use a non-zero Pause before meridian value (Options > Imaging > Meridian flip settings), then it might be challenging to use a Meridian Window, depending on your window size, minimum time settings, and meridian flip settings.  In most cases, using a Pause before meridian precludes using a Meridian Window.  See [Meridian Flip Safety](../concepts/planning-engine.html#meridian-flip-safety).

#### Horizon Determination

Your horizon (the altitude at any azimuth) used to determine target visibility is controlled as follows:
* If you set Use Custom Horizon to false, then your horizon is the value you set for Minimum Altitude.
* If you enable Use Custom Horizon, it will use the custom horizon for your NINA profile (from NINA Options > General > Astrometry) and calculate your visibility horizon as the greater of the custom horizon at each azimuth _or_ the Minimum Altitude setting.
* When using your Custom Horizon, you can also extend it towards the zenith by entering a Horizon Offset.  This can be used to add a few degrees to ensure you're clearing all obstructions.

The Minimum Altitude setting is therefore a 'floor' - you'll never try to image targets for the project while they are below this altitude, even if your Custom Horizon is lower.

Some equipment (for example long refractors with a substantial imaging train) may have difficulty pointing near the zenith without hitting the tripod or pier.  In this case, you can use the Maximum Altitude setting to restrict imaging to times when the target is below this value.

#### Filter Switch Frequency

The Filter Switch Frequency determines how exposures for different filters are scheduled.  For example, if you have exposure plans active for L, R, G, and B filters:
* A value of 1 will schedule LRGBLRGB... etc
* A value of 2 will schedule LLRRGGBBLL... etc
* A value of 0 will schedule LLLLLL... (until all desired L exposures are accepted), RRRRRR... etc.

The setting depends primarily on whether you have focus offsets for your filters configured.  You would typically use 0 if you do not have offsets configured to minimize the need for autofocus runs.

Filter Switch Frequency is also used to set the frequency for Smart Exposure Selection - see below.

Note that Filter Switch Frequency is ignored if you're using an [override exposure order](exposure-plans.html#override-ordering) for any Target under this Project.

#### Dithering

The Scheduler instruction can optionally schedule dithering for you.  If the dither setting is _N_, a dither will be added before the _N+1<sup>th</sup>_ occurrence of a filter.  Examples:
* Dither=1, LRGBLRGBLRGBLLL: LRGBdLRGBdLRGBdLdLdL
* Dither=2, LRGBLRGBLRGBLLL: LRGBLRGBdLRGBLdLL
* Dither=3, LRGBLRGBLRGBLLL: LRGBLRGBLRGBdLLL
* Dither=1, LLRRGGBBLLL: LdLRdRGdGBdBLdLdL
* Dither=2, LLRRGGBBLLL: LLRRGGBBdLLdL

Otherwise, you can set the value to 0.  In this case, you can either use a Dither After Exposures trigger instruction in the Triggers section of the sequencer container, or skip dithering altogether.

Notes:
* Dithering behavior is completely independent of the Filter Switch Frequency.
* Dithering is determined based on the _filter name_ as configured in NINA Options > Equipment > Filter Wheel.  Since you could have different exposure plans using the same filter, we want to ensure that when that filter is selected again, we dither appropriately.
* Any dither operation resets the count for all filters.
* The Dither setting is ignored if you're using an [override exposure order](exposure-plans.html#override-ordering) for any Target using this template.

You can also specify a per-filter dither value by [overriding it on exposure templates](exposure-templates.html#dithering).

#### Smart Exposure Selection
If Smart Exposure Selection is enabled, the planner will select the next exposure based on a calculated _moon avoidance score_.  If multiple exposure plans have the same (or nearly the same) high avoidance score, then the Filter Switch Frequency is used to decide when to which filters.

See [exposure selection](../concepts/planning-engine.html#exposure-selection-and-dithering) for additional details on how a selection method is determined.

#### Scoring Engine Rule Weights

Each rule for the [Scoring Engine](../concepts/planning-engine.html#scoring-engine) has an associated weight value that can be adjusted per project.  When the engine runs, the score for each rule is calculated for the target and then multiplied by the rule's weight value.  Weights can vary from 0 (disabling the rule entirely) to 100 (maximum effect).

You can copy and paste Rule Weights from one project to another.  You can also reset the weights back to the defaults.  Notes:
* Copy/paste and reset happen immediately **_outside_** of edit mode.
* The paste buffer is not cleared when you paste, making it easy to repeatedly copy the same set to multiple projects.
* Copy, paste, and reset are disabled if the Project is in edit mode.

{: .warning }
Again, the scoring rule weight copy/paste and reset operations are saved to the database **_immediately_** without any warning or chance to cancel.
