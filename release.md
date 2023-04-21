---
layout: default
title: Release Status
nav_order: 10
---

# Release Status

## Release 0.3.0.0

This release is only available for NINA 2.1.x.  Support for NINA 3 will be added later.

The plugin is currently in a **_pre-release_** state equivalent to early beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

### Change Log for 0.3.0.0
* Removed start and end date fields from projects
* Created a custom log for the plugin
* Added support for database migration scripts
* Fixed bug with plan end time

See the [project change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- There is a bug when editing the Exposure Template dropdown field of an Exposure Plan: it doesn't reflect the change when you tab out and appears to revert to the original.  However, when you save, it does save properly and display it.
- There is a potential problem with the target visibility determination for custom horizons.  Since the approach searches forward in time from target rising and backwards in time from setting, it could potentially miss an obstruction.  Ultimately, we'll need to solve by starting at the beginning of visibility and incrementing forward until the horizon (obstruction) is hit and use that as the real end time.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.
