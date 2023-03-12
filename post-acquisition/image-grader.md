---
layout: default
title: Image Grader
parent: Post-acquisition
nav_order: 3
---

# Image Grader

{: .warning}
Image Grading is a work in progress.  The following is not implemented and all images are marked as accepted.

In order to increase the level of automation, the plugin includes rudimentary image grading.  The grader will compare metrics (e.g. HFR and star count) for the current image to a set of immediately preceding images to detect significant deviations.  If the image fails the test, the accepted count on the associated Exposure Plan is not incremented and the scheduler will continue to schedule exposures.

Automatic image grading is inherently problematic and this plugin is not the place to make the final determination on whether an image is acceptable or not.  Towards that end, the plugin will **_never_** delete any of your images.  You are also free to disable Image Grading and manage the accepted count on your Exposure Plans manually - for example after reviewing the images yourself or using more sophisticated (external) analysis methods.

