---
layout: default
title: Post-acquisition
nav_order: 8
has_children: true
---

# Post-acquisition

When each exposure completes, the image is saved to disk.  The plugin listens for these save events and takes two actions:
* Save metadata for the image to the database.
* Optionally invoke the Image Grader to grade the image and increment (or not) the accepted count on the applicable Exposure Plan.
