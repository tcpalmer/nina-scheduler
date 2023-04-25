---
title: Home
layout: home
nav_order: 2
---

# Target Scheduler Plugin

Automation for astrophotography means different things to different people.  [NINA](https://nighttime-imaging.eu/) can certainly be scripted with the advanced sequencer to image multiple targets unattended over one or many nights.  But the burden remains to periodically rework - or completely redo - a sequence to handle different conditions and targets.

The Target Scheduler Plugin is designed to provide a higher level of automation than is typically achievable with NINA. Specifically, it maintains a database of imaging projects describing DSO targets and associated exposure plans. Based on various criteria and preferences, it can decide at any given time what project/target should be actively imaging.

You enter your desired projects, targets, and exposure plans into a UI exposed by the plugin. At runtime, a single new instruction for the NINA Advanced Sequencer will interact with the planning engine to determine the best target for imaging at each point throughout a night. The instruction will manage the slew/center to the target, switching filters, taking exposures, and (optionally) dithering - all while transparently interacting with the surrounding NINA triggers and conditions.

The goal of the plugin is not to squeeze every available second out of an imaging window.  You may have periods where it doesn't seem to be particularly optimal (hopefully reduced as the plugin improves).  It should, however, significantly reduce the configuration and setup burden associated with sophisticated, multi-target acquisition.

{: .warning }
The Target Scheduler Plugin is currently in a pre-release state - please read the [Release Status](release.html) page for more information.

## Getting Started
You should first familiarize yourself with the [concepts](concepts.html) underlying the plugin.  After that, visit the [Getting Started](getting-started.html) page for prerequisites and next steps.

Please also review the [release notes](release.html).

### Acknowledgements
* [Chris Woodhouse](https://www.digitalastrophotography.co.uk/about.html) has been involved since the beginning and was instrumental in hashing out the initial design and requirements.  He was also a willing guinea pig to test early releases.
* The concept for the plugin was originally inspired by the AIC video [Tim Hutchison: Automating a Backyard Observatory](https://youtu.be/a4IkAUZkXH0).
* Finally, it's a tribute to the elegant design of NINA and the Advanced Sequencer that a plugin of this type is not only possible, but can also interact correctly with other elements in a sequence.
