---
layout: default
title: Release Notes
nav_order: 10
---

# Release Notes 3.1.2.0

## Changes in this Release

This release is available for NINA 3.  Previous releases (0.8.0.0 and earlier) were for NINA 2.  From this point forward, only fixes for serious problems will be back-ported to the NINA 2 version.  This documentation is for the NINA 3 version only.

The plugin is currently in a **_pre-release_** state equivalent to early beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

### NINA 3

The primary change in this release is the port to NINA 3.  From this point forward, all new feature development with only be for the NINA 3 version.  Only serious bugs will be fixed in the NINA 2.x version.

### Custom Event Instructions

You can now drop arbitrary instructions into four separate containers that will be executed at specific times in the scheduler lifecycle:
- Before each Wait
- After each Wait
- Before each new/changed Target
- After each new/changed Target

For example, you could park your mount and/or close a flip-flat before a wait and then reverse after.  Or run an autofocus before each target begins imaging (and after it slews/centers on the chosen target).  See [Custom Event Instructions](sequencer/index.html#custom-event-instructions).

### Display of Running Instructions

The display of running instructions in the Target Scheduler Container instruction has been greatly improved.

### Scheduler Preview Details

Scheduler Preview now provides a [View Details](scheduler-preview.html#view-details) button to display details about the planning and decision-making process.  The same information is also written to the [Target Scheduler log](technical-details.html#logging) for actual runs via the sequencer.

### Target Rotation

NINA 3 changes the meaning of target rotation values.  From the NINA 3 release notes:
> Rotation values in N.I.N.A. are now displayed in counter clockwise notation to follow the standard of "East of North of North Celestial Pole" that is used in most astro applications. Templates, Targets and other saved items in previous versions will be auto migrated to this adjusted approach.

The new value is simply 360 minus the old value (and modulo 360).  Just as NINA will automatically convert old rotation values in your sequence files and templates, the plugin will convert target rotations in your database to the new approach when you first use the plugin.

Refer to the applicable documentation for details.  See the project [release notes](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/RELEASENOTES.md) and [change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- There is a bug when editing the Exposure Template dropdown field of an Exposure Plan: it doesn't reflect the change when you tab out and appears to revert to the original.  However, when you save, it does save properly and display it.
- There is a potential problem with the target visibility determination for custom horizons.  Since the approach searches forward in time from target rising and backwards in time from setting, it could potentially miss an obstruction.  Ultimately, we'll need to solve by starting at the beginning of visibility and incrementing forward until the horizon (obstruction) is hit and use that as the real end time.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.
