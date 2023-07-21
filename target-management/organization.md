---
layout: default
title: Organization
parent: Project / Target Management
nav_order: 6
---

# Project / Target Organization

The primary motivation for the project/target hierarchy is so that targets can share project properties and scoring rule weights.  Projects also serve to organize items in the various parts of the plugin user interface.

While having projects with only a single target can certainly be useful to achieve fine control of scheduling and imaging for each target, there are use cases for projects with multiple targets.

## Mosaics

Mosaics with two or more panels are an obvious match to the project/target hierarchy.  Since the panel coordinates will likely be close together, it's logical to consider those targets together.  And since the ultimate goal is a composite image, the imaging constraints will also be the same.  Any acquisition differences required by different filters can be handled by your exposure plans and templates on those targets.

The plugin also makes it simple to [import mosaic panels](projects.html#mosaic-panel-import) from the NINA Framing Assistant into a single parent project.

## Priority Projects

If you typically have one or two targets as the priority for some period of time, it's logical to group them together so you can complete imaging projects without waiting too long (like more than one season).  In this case you would set project priority to High, and perhaps adjust the scoring rule weights as well.

Other targets can be grouped into projects with Normal or Low priority so that clear skies aren't wasted if the high priority targets aren't available.


## Get What You Can

If you don't have any high priority targets but don't want to waste clear skies, then just have your projects with roughly equal priorities and rule weights.  The plugin should be pretty good at simply getting what images are possible on any given night.

## Testing

You can also use normal or low priority projects to slip in some imaging on an upcoming high priority target in order to test framing, exposures, filters, etc.  You could also relax constraints (e.g. altitude or moon avoidance) since high quality isn't the point. When it's time to raise the priority, you'll be ready to configure it appropriately.

## Surveys

The automation provided by the plugin is well-suited to performing survey operations like searching for new supernovas or imaging multiple areas looking for (perhaps undiscovered) faint nebulosity or other phenomena.  Such projects can be set up for quicker plans that optimize imaging - for example west to east priority (via the Setting Soonest scoring rule).

The upcoming feature to bulk load projects/targets will facilitate this type of work.
