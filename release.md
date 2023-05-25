---
layout: default
title: Release Notes
nav_order: 10
---

# Release Notes 0.7.1.0

This release is only available for NINA 2.  Support for NINA 3 will be added later.

The plugin is currently in a **_pre-release_** state equivalent to early beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

## Changes in this Release

### Meridian Window Support
This release adds support for restricting target imaging to a timespan around the target's meridian crossing in order to minimize airmass and light pollution impacts during acquisition.

A new rule for the Scoring Engine lets you set the priority of targets using meridian windows so they can be prioritized if desired.

### Default Exposure Times

You can now add a default exposure time to your Exposure Templates.  This duration will be used unless overridden in Exposure Plans that use the template.

If you have existing Exposure Plans and want to use this feature:
* Add the desired default to your Exposure Templates.
* In your Exposure Plans, simply clear the existing exposure value - it should change to '(Template)' to indicate usage of the default.

### Scheduler Loop Condition

A new [loop condition](sequencer/condition.html) is provided to support outer sequence containers designed for safety concerns and/or multi-night operation.  The condition has two options:
* While Targets Remain Tonight: continue as long as the Planning Engine indicates that additional targets are available tonight (either now or by waiting).  This is the default.
* While Active Projects Remain: continue as long as any active Projects remain.

'While Active Projects Remain' should **ONLY** be used in an outer loop designed for multi-night operation with appropriate instructions to skip to the next dusk.  Since you may have active targets that can't be imaged for months, if you used this without skipping to the next day it would call the planner endlessly until the sequence was stopped manually.

### New Profile Preferences

* Option to park the mount when the planner is waiting for the next target.
* Option to throttle exposure counts when not using image grading.
* Option to accept all improvements in star count and/or HFR during image grading.

### Miscellaneous

* Added airmass to acquired image data detail display.
* Fixed problem with ROI exposure capture.
* Fixed problem with including rejected exposure plans.
* Fixed bug causing crashes during plan previews.

Refer to the applicable documentation for details.  See the project [release notes](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/RELEASENOTES.md) and [change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- There is a bug when editing the Exposure Template dropdown field of an Exposure Plan: it doesn't reflect the change when you tab out and appears to revert to the original.  However, when you save, it does save properly and display it.
- There is a potential problem with the target visibility determination for custom horizons.  Since the approach searches forward in time from target rising and backwards in time from setting, it could potentially miss an obstruction.  Ultimately, we'll need to solve by starting at the beginning of visibility and incrementing forward until the horizon (obstruction) is hit and use that as the real end time.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.
