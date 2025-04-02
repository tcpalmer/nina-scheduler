---
layout: default
title: Migration
parent: Target Scheduler 5 Notes
nav_order: 2
---

# Migration from Earlier Versions to Version 5


## Database

Several changes were made to the TS database and an automatic database migration will be performed at NINA start the first time the version 5 runs.  However, to support rollback to TS 4, a copy of your TS database is saved to %localappdata%\NINA\SchedulerPlugin\schedulerdb-backup-pre-ts5.sqlite prior to the migration.  If you need to rollback, see [Rollback to TS 4](#rollback-to-ts-4) below.

If you have a large TS database - and particularly if you have a large number of acquired images - the migration can be slow, taking many 10s of seconds.  Subsequent NINA starts will behave normally.  NINA notifications will be displayed when the migration starts and ends.

## Sequence Files

During the development process, multiple classes changed name spaces.  Although this is typically transparent to the user, it does impact existing NINA sequence files since the fully qualified class name is used to refer to sequence items.  Note that this also applies to any sequence templates you have that refer to TS instructions.

You have two options to convert your sequence/template files.

### Replace Existing Sequence Items
If you load a sequence or template that referred to TS 4 instructions, you'll see errors where NINA couldn't recognise the item.  You can just delete each of those and replace with the same item from the Sequence Instruction list.  To support rollback to TS 4, you should save the corrected version as a copy.

### Automatic via Script
A simple Windows Powershell script is provided to rewrite sequence files to use the new TS names.  You can download the script [here](../assets/sequenceToTS5.ps1).  Follow these steps to run the script (assumes familiarity with running Windows Powershell scripts):
1. Move the script to the folder where you typically store sequence files, typically your Documents\N.I.N.A.
2. Open a Powershell command window.
3. Change directory to the same one storing your sequence or template files.
4. Run the script for each of your existing TS 4 sequence/template files:

```
sequenceToTS5.ps1 -file NAME.json -out NAME-TS5.json
```

The script won't overwrite your existing file - you have to provide a new name for the migrated copy.

## Rollback to TS 4

Version 5 saw significant testing during the beta release so rollback hopefully won't be necessary.  And since old versions of NINA plugins aren't available via the NINA interface, you would need to download the last TS version from the [repository](https://github.com/tcpalmer/nina.plugin.assistant/releases) and install manually.

If you the need steps to do this, contact @tcpalmer in the #target-scheduler channel on the NINA project [Discord server](https://discord.com/invite/rWRbVbw).  But since the problem may be encountered by other users, the proper approach is to correct version 5.
