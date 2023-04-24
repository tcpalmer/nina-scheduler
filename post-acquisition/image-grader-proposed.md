---
layout: default
title: Image Grader Proposed
parent: Post-acquisition
nav_order: 4
---

# Image Grader (Proposed)

In order to increase the level of automation, the plugin includes rudimentary image grading.  The grader will compare metrics (e.g. RMS guiding error, HFR, star count) for the current image to a set of immediately preceding images to detect significant deviations.  If the image fails the test, the accepted count on the associated Exposure Plan is not incremented and the scheduler will continue to schedule exposures.

Automatic image grading is inherently problematic and this plugin is not the place to make the final determination on whether an image is acceptable or not.  Towards that end, the plugin will **_never_** delete any of your images.  You are also free to disable Image Grading and manage the accepted count on your Exposure Plans manually - for example after reviewing the images yourself or using more sophisticated (external) analysis methods.

If you do elect to manually accept/reject, be aware that the [Planning Engine](../concepts.html#planning-engine) will continue to schedule exposures for all Exposure Plans where the number of accepted images is less than the number desired.  If you don't actively grade after each session, your plans may request excessive images of one plan at the expense of others.  In the future, a preference might be added to pause exposures on plans where the number of acquired images greatly exceeds the number desired (e.g. by 150%).

## Grading Approach

The following only applies if the applicable project has Image Grading enabled.

Grading is driven by a set of preferences that are specified for each NINA profile:
* **_Max Samples_**: the maximum number of recent images to use for sample determination
* **_Grade RMS_**: enable grading based on the total RMS guiding error during the exposure
* **_RMS Pixel Threshold_**: the threshold to accept/reject based on guiding RMS error (see below)
* **_Grade Detected Stars_**: enable grading for the number of detected stars
* **_Detected Stars Sigma Factor_**: the number of standard deviations surrounding the mean for acceptable star count values
* **_Grade HFR_**: enable grading for calculated image HFR
* **_HFR Sigma Factor_**: the number of standard deviations surrounding the mean for acceptable values of HFR

{: .note }
These preferences will be added to a new "Profile Preferences" section of the UI, location TBD.

The grader is invoked with the statistics for the latest image and will return true (acceptable) or false based on the following:
* If no grading metrics are enabled, the image is acceptable.
* If RMS error is enabled for grading:
  * Get the total RMS error for the exposure in arcseconds.
  * Determine the arcseconds/pixel of the primary imaging system.
  * Convert the RMS error into main camera pixels.
  * If the error value is greater than the RMS Pixel Threshold, then the image is not acceptable.
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

## Grading on RMS Error
Attached guiders can provide RMS error values sampled over the course of an exposure.  These values are provided in units of RMS error per guide camera pixel but can easily be scaled to RMS error in arcseconds.  Since NINA knows the focal length of the primary system and the pixel size of the main camera, we can determine the arcseconds/pixel of the primary system and convert the guiding error in arcseconds into error per main camera pixel.

The RMS Pixel Threshold is the maximum acceptable error in main camera pixels.  Values less than one are ideal but larger values can be acceptable depending on other factors.  In practice, it may be best to set this threshold fairly high so the grader only rejects images where guiding was clearly having problems.

## Notes
* Since sky conditions can vary from night to night and over the course of a night, the Max Samples value can be used to restrict the comparison sample size to those images most likely to have been captured under similar circumstances.  On the other hand, setting a larger value should capture more of the natural variance of the variable in question.
* It would be straightforward to add additional grading metrics using a similar variance approach.
