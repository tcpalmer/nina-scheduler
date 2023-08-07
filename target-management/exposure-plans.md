---
layout: default
title: Exposure Plans
parent: Project / Target Management
nav_order: 4
---

# Exposure Plans

Each target has one or more associated _Exposure Plans_ that describe the actual exposures to be taken.  An Exposure Plan only has a few properties - but it references an [Exposure Template](exposure-templates.html) that provides many more.

## Basic Operations

### Exposure Plan Creation

New Exposure Plans are added by navigating to the desired target, entering Edit mode, and clicking the Add exposure plan icon.  A new exposure plan is initialized with default values and always references the first Exposure Template for the applicable profile.

{: .note}
If you have not yet created any Exposure Templates for this profile, you will be warned and will have to create at least one before proceeding.

### Copy/Paste

When the target is _not_ in Edit mode, you can copy all Exposure Plans for a target and then paste them to the same or different target.  This is especially useful when you have imported the targets for a mosaic: create the Exposure Plans for one target then copy and paste to all of the others.

If you copy Exposure Plans from a target under one profile and then paste to a target under a different one, you will be notified that the referenced Exposure Templates have been reset to the default for the profile and you will have to edit them.

### Exposure Plan Editing

Exposure plan fields are edited in line in the same table used for viewing them.  Simply double-click a field and make your change.  You will have to tab-out of the field to enable the Save icon.

When done, click the Save icon for the Target to save your changes or the Cancel icon to cancel.

### Exposure Plan Deletion
When the target is _not_ in Edit mode, you can delete exposure plans by clicking the Delete icon.

### Exposure Plan Properties

|Property|Type|Description|
|:--|:--|:--|
|Template|dropdown|[Exposure Template](exposure-templates.html) to use for this plan.|
|Exposure|double|Exposure time in seconds.  Leave blank to use the default defined for the template.|
|Desired|integer|Number of desired images for this plan - see below.|
|Accepted|integer|Number of accepted images for this plan - see below.|
|Acquired|integer|Total number of images acquired for this plan.  Read only.|
 
### Number of Images

As part of an exposure plan, you set the total number of images you **_Desire_** for the plan.  The plugin will continue to schedule exposures for this plan as long as the number desired is greater than the number **_Accepted_**.

The number of Accepted images can either be automatically set by action of the [Image Grader](../post-acquisition/image-grader.html) (incremented for each image that passes) or the value can be managed manually if you prefer.  If you manage it manually however, you are responsible for adjusting the value after you have reviewed the latest images - otherwise the plugin will continue to schedule exposures even if the number Desired is surpassed.  The [Exposure Throttle](profiles.html#general-preferences) preference can be used to manage this behavior.

The number **_Acquired_** is incremented for each exposure and is read-only.
