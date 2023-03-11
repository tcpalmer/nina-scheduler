---
layout: default
title: Exposure Templates
parent: Project / Target Management
nav_order: 5
---

# Exposure Templates

_Exposure Templates_ provide the ability to set several exposure-related properties that are commonly used for the associated filter and the rig described by the applicable profile.  Configurable properties include gain, offset, binning, and camera readout mode.  You can also set the level of twilight and the moon avoidance parameters appropriate for the filter.

Each [Exposure Plan](exposure-plans.html) references a single Exposure Template.

## Basic Operations

### Exposure Template Creation

New Exposure Templates are added by WHAT.

### Exposure Template Editing


When done, click the Save icon to save your changes or the Cancel icon to cancel.

### Exposure Template Deletion

### Exposure Template Properties

|Property|Type|Description|
|:--|:--|:--|
|Name|string|DESC|
|Filter|dropdown|DESC|
|Gain|integer|DESC|
|Offset|integer|DESC|
|Binning|dropdown|DESC|
|Readout Mode|integer|DESC|
|Acceptable Twilight|dropdown|DESC|
|Moon Avoidance|boolean|DESC|
|Avoidance Separation|double|DESC|
|Avoidance Width|integer|DESC|
|Maximum Humidity|double|Not currently implemented.|
