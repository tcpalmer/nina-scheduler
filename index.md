---
title: Home
layout: home
nav_order: 2
---

# Target Scheduler

The Target Scheduler Plugin is designed to provide a higher level of automation than is typically achievable today with [NINA](https://nighttime-imaging.eu/). Specifically, it maintains a database of imaging projects describing DSO targets and associated exposure plans. Based on various criteria and preferences, it can decide at any given time what project/target should be actively imaging.

You enter your desired projects, targets, and preferences into a UI exposed by the plugin. At runtime, a single new instruction for the NINA Advanced Sequencer will interact with the planning engine to determine the best target for imaging at each point throughout a night. The instruction will manage the slew/center to the target, switching filters, taking exposures, and (optionally) dithering - all while transparently interacting with the surrounding NINA triggers and conditions.

The goal of the plugin is **_not_** to squeeze every available second out of an imaging window.  You may have periods where it doesn't seem to be particularly optimal (hopefully reduced as the plugin improves).  It should, however, significantly reduce the configuration and setup burden associated with sophisticated, multi-target acquisition.

{: .warning }
The Target Scheduler Plugin is currently in a pre-release state - please read the [Release Status](release.html) page for more information.

### Acknowledgements
* [Chris Woodhouse](https://www.digitalastrophotography.co.uk/about.html) has been involved since the beginning and was instrumental in hashing out the initial design and requirements.  He was also a willing guinea pig to test early releases.
* Pete and Steve of [RoboScopes](https://www.roboscopes.com/) also tested early versions and provided invaluable feedback.
* The concept for the plugin was originally inspired by the AIC video [Tim Hutchison: Automating a Backyard Observatory](https://youtu.be/a4IkAUZkXH0).


{: .fs-2 }
The Sequence Scheduler plugin and this documentation are provided 'as is' under the terms of the [Mozilla Public License 2.0](https://github.com/tcpalmer/nina.plugin.assistant/blob/main/LICENSE.txt).  View the source code at [https://github.com/tcpalmer/nina.plugin.assistant](https://github.com/tcpalmer/nina.plugin.assistant).

----

[Just the Docs]: https://just-the-docs.github.io/just-the-docs/
[GitHub Pages]: https://docs.github.com/en/pages
[README]: https://github.com/just-the-docs/just-the-docs-template/blob/main/README.md
[Jekyll]: https://jekyllrb.com
[GitHub Pages / Actions workflow]: https://github.blog/changelog/2022-07-27-github-pages-custom-github-actions-workflows-beta/
[use this template]: https://github.com/just-the-docs/just-the-docs-template/generate
