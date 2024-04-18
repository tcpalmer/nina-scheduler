---
layout: default
title: Target Scheduler Background Condition
parent: Advanced Sequencer
nav_order: 4
---

# Target Scheduler Background Condition

Target Scheduler Background Condition will periodically check if any targets remain for the night and interrupt the sequence if not.  Unlike [Target Scheduler Condition](condition.html), it runs in the background as long as its parent container is running - similar to a safety condition check.

As long as the Planning Engine indicates that additional targets are available tonight (either now or by waiting), the condition will not interrupt.  

Since running the Planning Engine is more expensive than other types of condition checks, it is only run once per minute.
