---
layout: default
title: Image Grader
parent: Post-acquisition
nav_order: 3
---

# Image Grader

{: .warning}
Image Grading is a work in progress and the following is not implemented.  The current behavior is if the Image Grader switch is enabled for a project, then all images will be marked as accepted.  If the grader is not enabled, then no images will be accepted by default and you must manage the accepted count manually.

In order to increase the level of automation, the plugin includes rudimentary image grading.  The grader will compare metrics (e.g. HFR and star count) for the current image to a set of immediately preceding images to detect significant deviations.  If the image fails the test, the accepted count on the associated Exposure Plan is not incremented and the scheduler will continue to schedule exposures.

Automatic image grading is inherently problematic and this plugin is not the place to make the final determination on whether an image is acceptable or not.  Towards that end, the plugin will **_never_** delete any of your images.  You are also free to disable Image Grading and manage the accepted count on your Exposure Plans manually - for example after reviewing the images yourself or using more sophisticated (external) analysis methods.

If you do elect to manually accept/reject, be aware that the [Planning Engine](../concepts.html#planning-engine) will continue to schedule exposures for all Exposure Plans where the number of accepted images is less than the number desired.  If you don't actively grade after each session, your plans may request excessive images of one plan at the expense of others.  In the future, a preference might be added to pause exposures on plans where the number of acquired images greatly exceeds the number desired (e.g. by 150%).
