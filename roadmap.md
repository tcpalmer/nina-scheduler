---
layout: default
title: Roadmap
nav_order: 11
---

# Future Development

## Scoring Engine Rules
The following new rules for the Scoring Engine are under consideration:
* Minimum Imaging Time: assign a higher priority to those targets that have less imaging time available.  For example, if you have a target that only rises high enough for a short time each year, it would score higher since it would have less availability.  (Overlaps with existing Setting Soonest rule).
* Meridian Flip: assign a lower score to targets that will require an immediate MF. Related: if a target is east of the meridian but ‘close’ (check NINA profile MF settings), don’t switch to it until it’s well past the meridian.

## General/Other
* Support for planning based on weather station data like humidity and sky quality.
* Prioritize Filters by moon avoidance or percent complete.
* Add a custom view panel for Target Scheduler activity that can be added to the main NINA Imaging tab.
* Save a thumbnail image with the image metadata.
* Ability to load targets in real time from [NASA's GCN](https://gcn.nasa.gov/) or similar alert networks and then interrupt imaging to switch to a high priority target.
