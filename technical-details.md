---
layout: default
title: Technical Details
nav_order: 9
---

# Technical Details

## Target Scheduler Container Operation

Some of the powerful core instructions in NINA actually work by leveraging other instructions internally.  For example, the Smart Exposure instruction is actually a sequence container that runs the instructions to switch filters, take exposures, and dither as needed - and then loops for the desired number of exposures.  All this happens transparently each time the instruction executes.

The Target Scheduler Container instruction takes a similar approach.  When a new target is returned by the Planning Engine, the instruction does the following:
* Instantiates an internal container to run the slew and imaging instructions specific to the target.
* Adds special triggers to the internal container:
  * A custom trigger to stop execution of the internal container at the end time of the applicable target plan (specifically, if the expected duration of the next instruction would exceed the end time).
  * If the project has specified dithering, then the core dither trigger is added.
* Clones any triggers on the parent Target Scheduler Container and adds them to this list (where they can get access to the current target if needed).
* Executes the internal target container.  When it completes, it calls the Planning Engine again to get the next target.

In NINA, containers can override the default execution strategy and that capability is used by the internal target container.  This strategy performs two functions:
* It monitors the progress of executing instructions and updates the status display in the parent Target Scheduler Container.
* It runs ancestor triggers and conditions as needed on the _parent_ of Target Scheduler Container, skipping that container itself.  We must skip execution of the triggers directly added to Target Scheduler Container since those only serve as the source for cloning into the internal target container.

## Logging
Since the plugin is rather complex, it logs to a separate file rather than the main NINA log.  These logs are saved in %localappdata%\NINA\SchedulerPlugin\Logs\ and follow the NINA log naming convention with 'TS-' prepended.  Like the main NINA logs, these will also be purged after 90 days.

This log defaults to Debug level and (currently) does not follow the logging level set for the main log in NINA Options.

## Database
The plugin uses a [SQLite](https://www.sqlite.org/index.html) database to store information.  This is the same database technology that NINA uses to store its local DSO catalog.

Each time the plugin starts up, it will save a backup copy of the database and keep the three most recent copies.  However, it's also recommended that you have some other mechanism to back up the database to a separate server.

## File Locations

* Like other NINA plugins, the plugin executable files are under %localappdata%\NINA\Plugins in the plugin's folder.
* The plugin stores user-specific data under %localappdata%\NINA\SchedulerPlugin - for example the database in schedulerdb.sqlite.
* Plugin logs are in %localappdata%\NINA\SchedulerPlugin\Logs\.
