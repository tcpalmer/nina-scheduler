---
layout: default
title: Release Notes
nav_order: 13
---

# Release Notes 4.1.1.3

## Changes in this Release

This release is available for NINA 3.  Only fixes for serious problems will be back-ported to the NINA 2 version.  This documentation is for the current NINA 3 version only.

* Fixed bug in TS Flats: if your project flats cadence is greater than 1, then it wasn't properly accounting for flats for the same filter already taken - you'd basically take too many.
* Fixed bug with determining target completeness when image grading is off and exposure throttling applies.
* Fixed missing TS version in TS log.

The release is a patch for the major release that introduced [automated flats](flats.html) for Target Scheduler.

## General

Refer to the applicable documentation for details.  See the project [release notes](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/RELEASENOTES.md) and [change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

The plugin is currently in a **_pre-release_** state equivalent to beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.
