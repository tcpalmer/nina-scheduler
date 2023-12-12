---
layout: default
title: Target Scheduler Flats
parent: Advanced Sequencer
nav_order: 4
---

# Flat Frames

Target Scheduler supports two instructions for taking flats.  Additional details and getting started information can be found in [Flat Frames](../flats.html).

## Target Scheduler Flats

This instruction takes flats periodically based on a project setting.  For example, you can set the cadence to two which means "don't let two days pass without taking the flats for the corresponding light sessions".  Rather than a cadence, you can set your project to only take flats once the targets are complete (exposure plans all 100% complete).

This instruction works for all applicable targets and is typically inserted into your sequence after you're done with imaging for the night.

It may _not_ be suitable if you're using a rotator and the operation isn't precisely repeatable which can lead to calibration problems.  The flats capability does record the mechanical position of the rotator but if it can't return to the exact same physical angle (due to backlash or other problems), then flats taken after the rotator has moved to a new position may not calibrate properly.  In this case, you can use the immediate flats instruction.

## Target Scheduler Immediate Flats

This instruction takes flats immediately after a target plan has run and will only take flats matching the corresponding lights from that target plan.  The instruction will not move the rotator and instead will assume it's in the location determined by the immediately preceding solve/rotate (which was used for the lights).

If you don't use a rotator, then it doesn't make sense to use this instruction since you'll be wasting dark sky time.  Instead, use Target Scheduler Flats which can run after imaging concludes for the night.
