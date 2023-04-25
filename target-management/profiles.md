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
