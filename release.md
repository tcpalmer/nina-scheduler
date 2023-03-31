---
layout: default
title: Release Status
nav_order: 10
---

# Release Status

## Release 0.2.0.0

This release is only available for NINA 2.1.x.  Support for NINA 3 will be added later.

The plugin is currently in a **_pre-release_** state equivalent to early beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
Later releases may require you to delete your existing database before installing.  A mechanism to migrate older schemas will be added in the future after the database stabilizes.  It's possible that any release prior to 1.0.0.0 will obsolete your database.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

### Change Log for 0.2.0.0

* Major refactoring of the plugin sequence containers.
* Added Setting Soonest scoring rule.  Although the database schema hasn't changed, any projects created prior to this release will not be able to use this rule.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- There is a bug when editing the Exposure Template dropdown field of an Exposure Plan: it doesn't reflect the change when you tab out and appears to revert to the original.  However, when you save, it does save properly and display it.
- If a profile is deleted, we may have Projects or Exposure Templates that no longer have a profile to attach to in the management UI navigation trees.  Best option is to create a special 'orphan' or 'trashcan' pseudo-profile and store them under that.  If desired, they could be copied to another profile and the original deleted.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.

