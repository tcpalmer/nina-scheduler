---
layout: default
title: Acquisition Data
parent: Post-acquisition
nav_order: 2
---

# Acquisition Data

The plugin saves metadata to the database for each exposure taken when the plugin is running the acquisition session.  This data can be viewed on the plugin home page (NINA Options > Plugins > Target Scheduler) by expanding the Acquired Images section.  Note that values may be empty if not applicable for your equipment.

Records can be filtered by date range, project, and target.  Click a table header to sort the table, click the same header again to sort in the opposite direction.  Select a row in the table to view details.  

The following values are saved.  The description is missing for items that are self-explanatory and/or come directly from underlying NINA data.

|Property|Description|
|:--|:--|
|Project ID|The database ID of the associated project|
|Target ID|The database ID of the associated target|
|Date|Date/time the exposure finished|
|Filter|Filter used for the exposure|
|Accepted|Whether the exposure was accepted or not|
|File Name|Full path to the image file on disk|
|Duration|Exposure duration|
|Gain||
|Offset||
|Binning||
|Stars||
|HFR||
|HFR Std Dev||
|ADU Std Dev||
|ADU Mean||
|ADU Median||
|ADU Min||
|ADU Max||
|Guiding RMS||
|Guiding RMS ArcSec||
|Guiding RMS RA||
|Guiding RMS RA ArcSec||
|Guiding RMS Dec||
|Guiding RMS Dec ArcSec||
|Focuser Position||
|Focuser Temp||
|Rotator Position||
|Pier Side||
|Camera Temp||
|Camera Target Temp||
|Airmass||

