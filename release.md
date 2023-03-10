---
layout: default
title: Release Status
nav_order: 10
---

## Release 0.1.0.0

This release is only available for NINA 2.1.x.  Support for NINA 3 will be added later.

The plugin is currently in a **_pre-release_** state equivalent to early beta.  If you are using a pre-release version, then please keep in mind the following.

{: .warning }
Later releases may require you to delete your existing database before installing.  A mechanism to migrate older schemas will be added in the future after the database stabilizes.  It's possible that any release prior to 1.0.0.0 will obsolete your database.

{: .warning }
By definition, pre-releases have had limited testing.  Hopefully, if something goes wrong the worst that could happen is that you lose imaging time.  However, the plugin is controlling your mount so could potentially drive it to an unwanted position.  It does use the built-in mount slew/rotate/center instructions so this is unlikely, but you would be wise to implement hard limits for your mount (configured outside NINA) just to be safe.

## Change Log
