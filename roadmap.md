---
layout: default
title: Roadmap
nav_order: 10
---

# Future Development

## Flat Frames

Since the Scheduler will know what images were acquired throughout a session, it could potentially generate the details to automatically take the associated flats.  Perhaps a new sequence instruction based on the existing Trained Flat Exposure instruction.

## Scoring Engine Rules
The following new rules for the Scoring Engine are under consideration:
* Minimum Imaging Time: assign a higher priority to those targets that have less imaging time available.  For example, if you have a target that only rises high enough for a short time each year, it would score higher since it would have less availability.  (Overlaps with existing Setting Soonest rule).
* Meridian Flip: assign a lower score to targets that will require an immediate MF. Related: if a target is east of the meridian but ‘close’ (check NINA profile MF settings), don’t switch to it until it’s well past the meridian.

## General/Other
* The issues with setting the [plan stop time](concepts/planning-engine.html#plan-window) will be addressed.
* Ability to delete a range of acquired image records.
* Support for planning based on weather station data like humidity and sky quality.
* Prioritize Filters by moon avoidance or percent complete.
* Add a custom view panel for Target Scheduler activity that can be added to the main NINA Imaging tab.
* Support for multiple OTAs/cameras on a single mount, similar to the Synchronization plugin.
* Save a thumbnail image with the image metadata.
* Ability to bulk load targets from a CSV or JSON file.
* Ability to load targets in real time from [NASA's GCN](https://gcn.nasa.gov/) or similar alert networks and then interrupt imaging to switch to a high priority target.
