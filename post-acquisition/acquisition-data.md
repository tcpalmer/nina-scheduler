---
layout: default
title: Acquisition Data
parent: Post-acquisition
nav_order: 3
---

# Acquired Images

The plugin saves metadata to the database for each exposure taken when the plugin is running the acquisition session - essentially the same metadata that NINA gathers and calculates for the image.  This data can be viewed on the plugin home page (NINA Plugins > Target Scheduler) by expanding the Acquired Images section.

In addition to providing the means to review acquisition data, the records are also used to provide samples for the [Image Grader](image-grader.html).  You can also manually change/override the grading status.

![](../assets/images/acquired-images-4.png)

## Filtering

Several options exist to restrict the records displayed.  To select by date:
* Select a preset date range from the Fixed Date Range dropdown.
* Or enter custom From and To dates.

So that the date range is inclusive, the From date will always have a time of midnight and the To date will use 23:59:59.

You can further restrict the records by Profile, Project, Target, and Filter used:
* Profile: Select a profile from the dropdown.
* Project: Select a project from the dropdown.
* Target: If you select a project, you can select one of the targets for that project.
* Filter: If you select a target, you can further select one of the filters used for that target.

## Viewing

* You can click a table header to sort the table, click the same header again to sort in the opposite direction.
* Select a row in the table to view details, including a thumbnail image of the exposure.

## Manual Grading

If the project associated with a record has enabled grading, then you can manually update the grading status.  This will also update the Accepted count of the associated exposure plan.  The following table shows the behavior and side-effects.

| Current Status | New Status | Note                                                                          |
|:---------------|:-----------|-------------------------------------------------------------------------------|
| Pending        | Accepted   | Exposure plan accepted count incremented by 1                                 |
| Pending        | Rejected   | Exposure plan unchanged.  Reject reason set to 'Manual'                       |
| Accepted       | Pending    | Exposure plan accepted count decremented by 1.                                |
| Accepted       | Rejected   | Exposure plan accepted count decremented by 1.  Reject reason set to 'Manual' |
| Rejected       | Pending    | Exposure plan unchanged. Reject reason cleared.                               |
| Rejected       | Accepted   | Exposure plan accepted count incremented by 1. Reject reason cleared.         |

To manually grade an acquired image record:
- Select (click) the desired row in the table to display the details.
- Update the status - Pending, Accepted, Rejected - as desired (to the right of the thumbnail).  The effect is immediate.

Note that if you change the status back to Pended, you have the option to let the [Image Grader](image-grader.html) automatically grade the image based on the current population of like records.  This can happen in one of two ways:
- If the target is still actively imaging the impacted exposure plan, then it should get graded when regular grading occurs for that plan.
- Alternatively, you can [manually trigger the grader](../target-management/exposure-plans.html#manual-grading).

### Problems

Some conditions might prevent a grading change:
- The project has disabled grading - perhaps even after the record was saved.
- The exposure plan associated with the record cannot be found.  In most cases, this is because it was removed from the target or the target was deleted.  However, versions of the plugin prior to 5 did not save the exposure plan reference at all.  If this is the case, you likely won't see the thumbnail image either.

## CSV Output

Click the CSV icon to write the results of the current query to a CSV file.  The output file does not reflect any sorting changes you make to the table itself.

The column order was chosen to mimic the CSV output of the Session Metadata plugin.

## Purging Records

To remove acquired image records, expand the Purge Records header.  There are two ways to select the records:
* By date: set the Older Than date to the date desired (it defaults to nine months before present) and leave Target as 'All'.  All records - regardless of target - will be removed.
* By date and target: set the Older Than date to the date desired and then select your target from the dropdown.  Only those records for that target older than the date will be removed.

Click the delete (trashcan) icon to execute.  In both cases, you will be asked to confirm the deletion.

### Notes
* Keep in mind that these records are used for image grading so if you think you might want to continue imaging a relevant target in the future, you might not want to remove associated records.
* There is only a weak reference to the applicable project, target, and filter for each record.  You could delete or move projects, targets, or exposure plans which may impact what can be shown, selected, or deleted.
* You can however, choose to automatically delete the records associated with targets when deleting projects and targets.  See the _Delete Acquired Images_ [preference](../target-management/profiles.html#profile-preferences) (enabled by default).

## Data Saved

The following values are saved (although not all may be displayed).  The description is missing for items that are self-explanatory and/or come directly from underlying NINA data.  Note that some values may be empty if not applicable for your equipment.

| Property               | Description                                                 |
|:-----------------------|:------------------------------------------------------------|
| Acquired Date          | Date/time the exposure finished                             |
| Project                | The associated project                                      |
| Target                 | The associated target                                       |
| Filter                 | Filter used for the exposure                                |
| Exposure (secs)        | Exposure duration                                           |
| Exposure Template      | Name of the associated Exposure Template                    |
| Image File             | Full path to the image file on disk                         |
| Profile                | Name of the associated NINA profile                         |
| Gain                   |                                                             |
| Offset                 |                                                             |
| Binning                |                                                             |
| Stars                  |                                                             |
| HFR                    |                                                             |
| FWHM                   | Requires Hocus Focus                                        |
| Eccentricity           | Requires Hocus Focus                                        |
| Airmass                |                                                             |
| ADU Std Dev            |                                                             |
| ADU Mean               |                                                             |
| ADU Median             |                                                             |
| ADU Min                |                                                             |
| ADU Max                |                                                             |
| Guiding RMS            |                                                             |
| Guiding RMS ArcSec     |                                                             |
| Guiding RMS RA         |                                                             |
| Guiding RMS RA ArcSec  |                                                             |
| Guiding RMS Dec        |                                                             |
| Guiding RMS Dec ArcSec |                                                             |
| Focuser Position       |                                                             |
| Focuser Temp           |                                                             |
| Rotator Position       |                                                             |
| Pier Side              |                                                             |
| Camera Temp            |                                                             |
| Camera Target Temp     |                                                             |
| Airmass                |                                                             |
| Accepted               | Exposure grading status: Pending, Accepted, or Rejected.    |
| Rejected Reason        | Reason for rejection, if not accepted by the Image Grader.  |

