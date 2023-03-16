---
layout: default
title: Targets
parent: Project / Target Management
nav_order: 3
---

# Targets

A _Target_ represents a single DSO object with RA/Dec coordinates, frame rotation, and ROI.  A target always has a parent project and inherits those project properties.

Target coordinates can be manually entered or imported from the NINA catalog, the NINA Framing Assistant, targets saved for the advanced sequencer, or an attached planetarium program (e.g. Stellarium).

[Exposure Plans](exposure-plans.html) are also managed from the Target view/edit panel - see that page for details.

## Basic Operations

### Target Creation

New targets are added by navigating to the desired project and then clicking the Add icon.  The new target is saved, added to the navigation tree, and selected.  Click the Edit icon to make changes.

### Target Editing

Click the Edit icon to begin editing the target.  The property value fields become active and you can make changes.  Note that you typically have to tab out after editing to enable the Save icon.

To import a target, click the Edit icon to begin editing.  Then click the Import icon on the far right.  This will open a section with three import options:
* **NINA Catalog**. Enter the name of your DSO in the field - incremental search is supported.  Be sure to click on your selection to set the coordinates.
* **Framing Assistant**. If you have previously framed a target using the NINA Framing Assistant, click the icon to import those coordinates.
* **Sequence Target**.  In the Advanced Sequencer, you can save DSO Sequence containers to be reused (they appear under the Targets tab in the Advanced Sequencer upper right).  You can import those targets by clicking the icon.
* **Planetarium**. If you have configured the NINA connection to your planetarium software (Options > Equipment > Planetarium), click the icon to import coordinates from that source.

When done, click the Save icon to save your changes or the Cancel icon to cancel.

### Target Properties

|Property|Type|Description|
|:--|:--|:--|
|Name|string|The name of the target.  If you import a target, it will get the name from the import source.|
|Active|boolean|Enable/disable the target.  Disabled targets are not considered for scheduling.|
|Coordinates|HMS, DMS|The RA and Dec coordinates of the target.|
|Rotation|degrees 0-360|Frame rotation for the target.  If a rotator is attached, it will be set to this angle.  If a target is imported and the source supports rotation, it will be set on import.|
|ROI|integer 1-100|Region of Interest, will operate the same as the existing Take Subframe Exposure instruction.|

