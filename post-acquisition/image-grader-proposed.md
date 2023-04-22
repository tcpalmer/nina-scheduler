---
layout: default
title: Image Grader Proposed
parent: Post-acquisition
nav_order: 4
---

# Image Grader (Proposed)

In order to increase the level of automation, the plugin includes rudimentary image grading.  The grader will compare metrics (e.g. HFR and star count) for the current image to a set of immediately preceding images to detect significant deviations.  If the image fails the test, the accepted count on the associated Exposure Plan is not incremented and the scheduler will continue to schedule exposures.

Automatic image grading is inherently problematic and this plugin is not the place to make the final determination on whether an image is acceptable or not.  Towards that end, the plugin will **_never_** delete any of your images.  You are also free to disable Image Grading and manage the accepted count on your Exposure Plans manually - for example after reviewing the images yourself or using more sophisticated (external) analysis methods.

If you do elect to manually accept/reject, be aware that the [Planning Engine](../concepts.html#planning-engine) will continue to schedule exposures for all Exposure Plans where the number of accepted images is less than the number desired.  If you don't actively grade after each session, your plans may request excessive images of one plan at the expense of others.  In the future, a preference might be added to pause exposures on plans where the number of acquired images greatly exceeds the number desired (e.g. by 150%).

## Grading Approach

The following only applies if the applicable project has Image Grading enabled.

Grading is driven by a set of preferences that are specified for each NINA profile:
* Max Samples: the maximum number of recent images to use for sample determination
* Grade Detected Stars: enable grading for the number of detected stars
* Detected Stars Sigma Factor: the number of standard deviations surrounding the mean for acceptable star count values
* Grade HFR: enable grading for calculated image HFR
* HFR Sigma Factor: the number of standard deviations surrounding the mean for acceptable values of HFR

{: .note }
These preferences will be added to a new "Profile Preferences" section of the UI, location TBD.

The grader is invoked with the statistics for the latest image and will return true (acceptable) or false based on the following:
* If neither star counts nor HFR are enabled for grading, the image is acceptable.
* Retrieve the metadata for the most recent accepted images that match the current image:
  * Same target
  * Same filter
  * Same rotation
  * Same exposure length, gain, offset, and binning
* If the number of matching images is less than three, the image is acceptable.
* If the number of matching images is greater than Max Samples, then select only the most recent Max Samples images.
* If detected star count is enabled for grading:
  * Determine the mean and standard deviation of the star counts in the matching images.
  * If the star count of the current image is _**not**_ within (star count sigma factor * standard deviation) of the mean, then the image is not acceptable.
* If HFR is enabled for grading:
  * Determine the mean and standard deviation of the HFR values in the matching images.
  * If the HFR of the current image is _**not**_ within (HFR sigma factor * standard deviation) of the mean, then the image is not acceptable.

## Notes
* Since sky conditions can vary from night to night and over the course of a night, the Max Samples value can be used to restrict the comparison sample size to those images most likely to have been captured under similar circumstances.  On the other hand, setting a larger value should capture more of the natural variance of the variable in question.
* It would be straightforward to add additional grading metrics using a similar variance approach, for example Guiding RMS.
