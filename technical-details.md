---
layout: default
title: Technical Details
nav_order: 9
---

# Technical Details

## Database
The plugin uses a [SQLite](https://www.sqlite.org/index.html) database to store information.  This is the same database technology that NINA uses to store its local DSO catalog.

It's recommended that you have some backup mechanism for the database to avoid losing your work.

## File Locations

* Like other NINA plugins, the plugin executable files are under %localappdata%\NINA\Plugins in the plugin's folder.
* The plugin stores user-specific data under %localappdata%\NINA\SchedulerPlugin - for example the database in schedulerdb.sqlite.

## Sequencer Operation

TBD...
