---
layout: default
title: Roadmap
nav_order: 9
---

# Future Development

## General
* Implement the Image Grader.
* Support for the meridian window restriction.
* Save a thumbnail image with the image metadata.
* Provide ability to bulk load targets from a CSV file.
* Support undo/redo operations in the database (maybe).

## Scoring Engine Rules
The following new rules for the Scoring Engine are under consideration:
* Meridian Flip: assign a lower score to targets that will require an immediate MF. Related: if a target is east of the meridian but ‘close’ (check NINA profile MF settings), don’t switch to it until it’s well past the meridian. 
* Mosaic completion priority: assign a higher score to mosaic targets that are closer to 100% complete to wrap them up. 
* Mosaic balance priority: assign a higher score to mosaic targets that are closer to 0% complete to balance exposures across frames. (Obviously in conflict with Mosaic completion priority so only one should be used.)

## Flat Frames

Since the Scheduler will know what images were acquired throughout a session, it could potentially generate the details to automatically take the associated flats.  Perhaps a new sequence instruction based on the existing Trained Flat Exposure instruction.
