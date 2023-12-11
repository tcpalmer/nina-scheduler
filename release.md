---
layout: default
title: Release Notes
nav_order: 13
---

# Release Notes 4.1.X.X

## Changes in this Release

This release is available for NINA 3.  Only fixes for serious problems will be back-ported to the NINA 2 version.  This documentation is for the current NINA 3 version only.

### Automated Flats
Target Scheduler can now automate flats generation for your targets.  Two new instructions support this capability:
* **_Target Scheduler Flats_**
* **_Target Scheduler Immediate Flats_**

See [Flat Frames](flats.html) for details.

The flats capability also introduces the concept of a Target Scheduler _session identifier_ that can link flats to the associated lights.  The value is made available by a custom Image Pattern named \$\$TSSESSIONID\$\$.  The pattern can be used in your image file patterns (Options > Imaging) just like \$\$FILTER\$\$ or \$\$TARGETNAME\$\$.  The value is just a number in a fixed-width string like '0001' or '0023'.  See [Session Identifier](flats.html#session-identifier-for-lights-and-flats).

### Target Scheduler Condition
* The condition check was optimized - now only tests after all instructions in the container are complete (not after each instruction).
* Added a 'While Flats Needed' check - continue as long as the [Target Scheduler Flats](flats.html#target-scheduler-flats) instruction has flats to take.

See [Target Scheduler Condition](sequencer/condition.html) for details.

## General

Refer to the applicable documentation for details.  See the project [release notes](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/RELEASENOTES.md) and [change log](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/CHANGELOG.md) for the complete history.

The plugin is currently in a **_pre-release_** state equivalent to beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

## Known Issues

- Icons disappear when using Light or Seance color schemes.
- Currently, a slew will always do a center which will also rotate a dome if connected.  However, if we provide a way to disable plate solving, then it would use the SlewScopeToRaDec instruction which does not rotate a dome.  Could possibly add a SynchronizeDome instruction with the slew.  Would need someone with a dome to disable platesolving and test such a fix.
- Although profiles/projects/targets are initially sorted properly, adding one or changing a name doesn't properly re-sort.  However, you can click the refresh icon on the tree to restore the sort order.
