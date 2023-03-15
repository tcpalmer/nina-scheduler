---
layout: default
title: FAQs
nav_order: 4
---

# Frequently Asked Questions

_Why is my project/target not considered at imaging time?_

> Be sure your project is in the Active state and the current date is between the project start/end dates.  In the management UI, click the profile name containing the project to show all projects.  The project should have a green checkmark if it's truly active.

_My target is active but still isn't being considered for imaging - why?_

> There could be many reasons:
> - It might not have risen about the horizon.
> - The current level of darkness might be inappropriate for the defined exposure plans/templates.
> - The project/target may have scored lower than others so the imaging time was allotted elsewhere.

_Can the plugin handle asteroids, comets, or other solar system objects?_

> No.  NINA is primarily for DSO imaging.  Although there are plugins that support non-DSOs, the Target Scheduler does not.

_Why can't I import a target from my planetarium software?_

> Import from planetarium software will only work if the software is properly configured in NINA Options > Equipment.  If import isn't working in the Framing Assistant, it's not going to work for target import.

_Will the plugin work with mount X, camera Y, or filter wheel Z?_

> If the equipment works properly today in the NINA Advanced Sequencer, then it should work properly with the plugin since it uses the same underlying NINA instructions to move the mount, operate the camera, and rotate the filter wheel.

_I have a dome - will the slew instructions used by the plugin rotate my dome properly?_

> Assuming your dome is properly configured with the associated NINA profile, then yes: the plugin will use the underlying NINA slew instruction which detects if a suitable dome is connected and rotates it.

_Will the plugin work correctly with my safety setup?_

> Assuming your safety configuration works properly with the associated NINA profile, then the plugin should interact with that system properly.  Since the plugin instruction is in many ways similar to the Deep Sky Object Sequence container instruction, it will interact with surrounding instructions and triggers in a similar manner.

_Can I use the plugin in conjunction with the NINA Synchronization plugin?_

> This will be possible but will require additional development work.

_I plan to image from a remote site in the near future.  How will the plugin handle that?_

> Simply create a new profile (NINA Options > General > Astrometry) with the site location.  If the remote site is in a different time zone, you should also reset the Windows time zone when you arrive.
