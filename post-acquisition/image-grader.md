---
layout: default
title: Image Grader
parent: Post-acquisition
nav_order: 1
---

# Image Grader

In order to increase the level of automation, the plugin includes rudimentary image grading.  The grader will compare metrics (e.g. RMS guiding error, HFR, star count) for the current image to a set of immediately preceding images to detect significant deviations.  If the image fails the test, the accepted count on the associated Exposure Plan is not incremented and the scheduler will continue to schedule exposures.

You can also choose to delay grading until some percentage of desired exposures have been acquired.  This can potentially mitigate problems caused when early images are taken under better conditions than those taken later - and the later images are incorrectly rejected.  By waiting until a larger set of exposures has been taken, you have a greater chance of using a more representative population.

Automatic image grading is inherently problematic and this plugin is not the place to make the final determination on whether an image is acceptable or not.  Towards that end, the plugin will **_never_** delete any of your images.  You are also free to disable Image Grading and manage the accepted count on your Exposure Plans manually - for example after reviewing the images yourself or using more sophisticated (external) analysis methods.

Note however that when grading is disabled, the percent complete calculation for an Exposure Plan is independent of the Accepted count and instead only depends on the Acquired count and the [Exposure Throttle](../target-management/profiles.html#general-preferences) preference.  See [Exposure Plans](../target-management/exposure-plans.html#number-of-images--percent-complete) for more information.

## Grading Approach

The following only applies if the applicable project has Image Grading enabled.

Grading is driven by a set of [preferences](../target-management/profiles.html#image-grader) that are specified for each NINA profile:
* **_Enable RMS Error Grading_**: enable grading based on the total RMS guiding error during the exposure
* **_Enable Star Count Grading_**: enable grading for the number of detected stars
* **_Enable HFR Grading_**: enable grading for calculated image HFR
* **_Enable FWHM Grading_**: enable grading for calculated image FWHM
* **_Enable Eccentricity Grading_**: enable grading for calculated image Eccentricity
* **_Accept All Improvements_**: if true, automatically accept an image if the metric shows an improvement compared to the mean
* **_Move Rejected Images_**: if true and a graded image was rejected, it will be moved to a ‘rejected’ folder under the image save folder
* **_Max Samples_**: the maximum number of recent images to use for sample determination (does not apply for delayed grading)
* **_Delay Grading_**: delay grading until some percentage of total desired has been taken
* **_RMS Pixel Threshold_**: the threshold to accept/reject based on guiding RMS error (see below)
* **_Stars Sigma Factor_**: the number of standard deviations surrounding the mean for acceptable star count values
* **_HFR Sigma Factor_**: the number of standard deviations surrounding the mean for acceptable values of HFR
* **_FWHM Sigma Factor_**: the number of standard deviations surrounding the mean for acceptable values of FWHM
* **_Eccentricity Sigma Factor_**: the number of standard deviations surrounding the mean for acceptable values of Eccentricity
* **_HFR Auto Accept Level_**: the threshold to automatically accept images for HFR
* **_FWHM Auto Accept Level_**: the threshold to automatically accept images for FWHM
* **_Eccentricity Auto Accept Level_**: the threshold to automatically accept images for Eccentricity

{: .note }
FWHM and Eccentricity grading are dependent on having the Hocus Focus plugin installed, enabled, and set up for Star Detection (Fit PSF ON). Be sure you have also enabled Hocus Focus in NINA Options > Imaging > Image options > Star Detector.

When exposures are first captured, they are marked with a grading status of _Pending_.  When grading is triggered for an image, the first step is determine the sample to be used for comparison.  This depends on whether delayed grading is enabled or not.
* If delayed grading is not enabled, the sample will consist of the most recent N matching exposures, where N is >= 3 and <= Max Samples.
* Otherwise, the sample is all matching exposures with the current exposure skipped.

The grader is invoked with the statistics for the latest image and will return true (acceptable) or false based on the following:
* If no grading metrics are enabled, the image is acceptable.
* If RMS error is enabled for grading:
  * Get the total RMS error for the exposure in arcseconds.
  * Determine the arcseconds/pixel of the primary imaging system.
  * Convert the RMS error into main camera pixels.
  * If the error value is greater than the RMS Pixel Threshold, then the image is not acceptable.
* Retrieve the metadata for the matching sample images that match the current image in:
  * Same profile
  * Same target and exposure plan
  * Same filter
  * Same ROI
  * Same rotation
  * Same exposure length, gain, offset, and binning
* If grading is disabled:
  * If the number of matching images is less than three, the image is acceptable.
  * If the number of matching images is greater than Max Samples, then select only the most recent Max Samples images.
* If detected star count is enabled for grading:
  * Determine the mean and standard deviation of the star counts in the matching sample images.
  * If Accept All Improvements is true and the star count of the current image is greater than the mean, then the image is acceptable for star count.
  * Otherwise, if the star count of the current image is _**not**_ within (star count sigma factor * standard deviation) of the mean, then the image is not acceptable.
* If HFR is enabled for grading:
  * Determine the mean and standard deviation of the HFR values in the matching sample images.
  * If Accept All Improvements is true and the HFR of the current image is less than the mean, then the image is acceptable for HFR.
  * If the HFR of the current image is less than the HFR Auto Accept Level, then the image is acceptable for HFR.
  * Otherwise, if the HFR of the current image is _**not**_ within (HFR sigma factor * standard deviation) of the mean, then the image is not acceptable.
* If FWHM is enabled for grading:
  * Determine the mean and standard deviation of the FWHM values in the matching sample images.
  * If Accept All Improvements is true and the FWHM of the current image is less than the mean, then the image is acceptable for FWHM.
  * If the FWHM of the current image is less than the FWHM Auto Accept Level, then the image is acceptable for FWHM.
  * Otherwise, if the FWHM of the current image is _**not**_ within (FWHM sigma factor * standard deviation) of the mean, then the image is not acceptable.
* If Eccentricity is enabled for grading:
  * Determine the mean and standard deviation of the Eccentricity values in the matching sample images.
  * If Accept All Improvements is true and the Eccentricity of the current image is less than the mean, then the image is acceptable for Eccentricity.
  * If the Eccentricity of the current image is less than the Eccentricity Auto Accept Level, then the image is acceptable for Eccentricity.
  * Otherwise, if the Eccentricity of the current image is _**not**_ within (Eccentricity sigma factor * standard deviation) of the mean, then the image is not acceptable.

The grading status of the image will be updated to _Accepted_ or _Rejected_.  If rejected and Move Rejected Images is enabled, the image will be moved to the 'rejected' folder.

## Grading on RMS Error
Attached guiders can provide RMS error values sampled over the course of an exposure.  These values are provided in units of RMS error per guide camera pixel but can be scaled to RMS error in arcseconds.  Since NINA knows the focal length of the primary system and the pixel size of the main camera, we can determine the arcseconds/pixel of the primary system and convert the guiding error in arcseconds into error per main camera pixel.

The RMS Pixel Threshold is the maximum acceptable error in main camera pixels.  Values less than one are ideal but larger values can be acceptable depending on other factors.  In practice, it may be best to set this threshold fairly high so the grader only rejects images where guiding was clearly having problems.

Since this calculation depends on accurate values for the focal length of the primary system and the pixel size of the main camera, those must be set correctly (in NINA Options > Equipment > Telescope and NINA Options > Equipment > Camera) for RMS error grading to work properly.

## Notes
* Since sky conditions can vary from night to night and over the course of a night, the Max Samples value can be used to restrict the comparison sample size to those images most likely to have been captured under similar circumstances.  On the other hand, setting a larger value should capture more of the natural variance of the variable in question.
* It would be straightforward to add additional grading metrics using a similar variance approach.
* If you capture a set of images under truly excellent seeing conditions and those images are accepted, subsequent images under average conditions may be rejected even though they are perfectly acceptable.  For this reason, delayed grading is enabled by default with a trigger threshold of 80% (acquired/desired).
