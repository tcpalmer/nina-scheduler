---
layout: default
title: FAQs
nav_order: 4
---

# Frequently Asked Questions

_Why is my project/target not considered at imaging time?_

> Be sure your project is in the Active state.  In the management UI, click the profile name containing the project to show all projects.  The project should have a green checkmark if it's truly active (project active and at least one target active with incomplete exposure plans).

_My target is active but still isn't being considered for imaging - why?_

> There could be many reasons:
> - It might be associated with a NINA profile that isn't currently active.
> - It might not have risen about the horizon.
> - The current level of darkness might be inappropriate for the defined exposure plans/templates.
> - It might be visible but not for the project's minimum imaging time.
> - The project/target may have scored lower than others so the imaging time was allotted elsewhere.
> - All exposure plans could have been rejected for moon avoidance or because they are complete.

_The scheduler doesn't seem to be doing what I expected.  Why not?_

> With all the potential factors that can impact planning decisions, the process can get quite complex.  Assuming you haven't found a bug, you should try to reduce the complexity of your active projects and targets until it makes sense.  For example:
> * Have only a single project active
> * If you do have more than one project/target active, be sure the Scoring Engine rules on each project make sense.
> * Use a minimum altitude on your project instead of a custom horizon.
> * Disable Moon Avoidance on your Exposure Templates
> * Set all applicable Exposure Templates to use the same twilight level
> 
> It might also help to use a planetarium program like Stellarium to check your target, timing, and circumstances and compare against the scheduler.
> 
> The [Scheduler Preview](scheduler-preview.html) is a great tool to see what the Planning Engine will do - just be aware of the differences between preview and real execution in the NINA Sequencer.  You can also use the View Details button on the previewer to see details on the planning process, including targets considered and scoring runs.

_I don't see much from the plugin in the NINA log - isn't it logging?_

> The plugin logs to a [separate log file](technical-details.html#logging) so that messages aren't lost amid all the other logging.

_Can the plugin handle asteroids, comets, or other solar system objects?_

> No.  NINA is primarily for DSO imaging.  Although there are plugins that support non-DSOs, the Target Scheduler does not.

_Will the plugin stop tracking and guiding while it's waiting for the next target?_

> Yes - it will stop where it is.  If you want the mount to park, you can set a [profile preference](target-management/profiles.html#profile-preferences) to park during waits.  Or use the [Before/After Wait containers](sequencer/index.html#custom-event-instructions) on the Target Scheduler instruction to perform custom operations at those times.

_Can I make changes to projects, targets, or exposure plans while it's running?_

> Yes.  The target currently running in the Target Scheduler Container won't see the changes but they will be picked up the next time the Planning Engine runs.

_Why can't I import a target from my planetarium software?_

> Import from planetarium software will only work if the software is properly configured in NINA Options > Equipment.  If planetarium import isn't working in the NINA Framing Assistant, it's not going to work for target import.

_Will the plugin work with mount X, camera Y, or filter wheel Z?_

> If the equipment works properly today in the NINA Advanced Sequencer, then it should work properly with the plugin since it uses the same underlying NINA instructions to move the mount, operate the camera, and rotate the filter wheel.

_Can I update the TS database directly?_

> Yes - see [Database Access and Updates](adv-topics/database.html).

_I have a mosaic project with multiple panels and want to balance exposures across the panels.  Is this possible?_

> Yes - by adjusting [scoring engine rule weights](concepts/planning-engine.html#scoring-engine-1).  Set the weight for Mosaic Completion high and the Percent Complete and Target Switch Penalty weights to zero.

_Why doesn't the plugin support manual filter trays or manual rotators?_

> Having to pause the sequence to alert the user to make a manual change in the middle of a session is inconsistent with the primary purpose of the plugin: supporting higher levels of automation.

_I have a dome - will the slew instructions used by the plugin rotate my dome properly?_

> Assuming your dome is properly configured with the associated NINA profile, then yes: the plugin will use the underlying NINA slew instruction which detects if a suitable dome is connected and rotates it.

_Will the plugin work correctly with my safety setup?_

> Assuming your safety configuration works properly with the associated NINA profile, then the plugin should interact with that system properly.  Since the plugin instruction is in many ways similar to the Deep Sky Object Sequence container instruction, it will interact with surrounding instructions and triggers in a similar manner.  You may need to use the [Target Scheduler Condition](sequencer/condition.html) for additional loop control.

_With the plugin work with NINA sequence instruction X?  How about instructions added by plugins?_

> See the [notes](sequencer/notes.html#core-sequence-items) on core and plugin sequence items.

_Can I use the plugin in conjunction with the NINA Synchronization plugin?_

> No but Target Scheduler has its own instructions to support [synchronization](synchronization.html).

_I plan to image from a remote site in the near future.  How will the plugin handle that?_

> Simply create a new profile (NINA Options > General > Profiles) and set the location (NINA Options > General > Astrometry).  If the remote site is in a different time zone, remember to reset the Windows time zone when you arrive.
