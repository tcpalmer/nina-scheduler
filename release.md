---
layout: default
title: Release Notes
nav_order: 10
---

# Release Notes 3.3.0.0

## Changes in this Release

This release is available for NINA 3.  Only fixes for serious problems will be back-ported to the NINA 2 version.  This documentation is for the current NINA 3 version only.

### Exposure Ordering Override

You can now override the default exposure ordering (which is based on the Filter Switch Frequency and Dither settings on the project) and specify a manual [override ordering](target-management/exposure-plans.html#exposure-order), including dithers.  Override orders are managed at the bottom of the Target view/edit panel.

Refer to the applicable documentation for details.  See the project [release notes](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/RELEASENOTES.md) and [change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

The plugin is currently in a **_pre-release_** state equivalent to beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- There is a potential problem with the target visibility determination for custom horizons.  Since the approach searches forward in time from target rising and backwards in time from setting, it could potentially miss an obstruction.  Ultimately, we'll need to solve by starting at the beginning of visibility and incrementing forward until the horizon (obstruction) is hit and use that as the real end time.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.
