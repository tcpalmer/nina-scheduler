---
layout: default
title: Getting Started
nav_order: 5
---

# Getting Started

The Target Scheduler is more complex than the average NINA plugin.  Successful use requires that you understand the plugin [concepts](concepts.html) and ensure that you have met the prerequisites.

{: .note }
Before you ask for help, please be sure you have met the following prerequisites and made an effort to understand how the plugin operates.

## Prerequisites
* Do not use the plugin if you are a new NINA user. 
* The plugin is designed for DSO imagers using monochrome astrophotography cameras with a filter wheel.  Future releases will have more support for color cameras, DSLRs, manual filter switching, etc.
* You should be reasonably adept at using the NINA Advanced Sequencer, understanding the concepts behind instructions, sequence containers, and triggers.
* You should already have NINA configured with at least one profile describing your location, camera, filter wheel, etc.
* Your filter wheel configuration should be stable.  If you later change the filter names (even 'L' to 'Lum') you might encounter issues with old references to 'L'.
* You should be able to successfully run sessions via the Advanced Sequencer with this profile.  The inevitable glitches with new equipment should have been worked out.
* Sky conditions notwithstanding, your sequences should be able to reliably plate solve and execute meridian flips without intervention.
* You are familiar with the plugin's [concepts](concepts.html).

## First Steps
These steps assume you have already installed the plugin via the NINA Plugins page.

There are two main points of interaction with the plugin's capabilities.
* The plugin home page (in the NINA Plugins tab) provides the UI to manage the [Project / Target Database](target-management/index.html), [preview schedules](scheduler-preview.html), and view metadata on [acquired images](post-acquisition/index.html).
* The plugin adds a single new instruction named **_Target Scheduler_** that you will add to your sequence.  See the [Advanced Sequencer](sequencer/index.html) for details.
