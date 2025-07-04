---
layout: default
title: Project / Target Management
nav_order: 6
has_children: true
---

# Project and Target Management

The plugin provides a UI to manage your projects, targets, and exposure plans.  Through the interface, you can add new projects and targets, add and update exposure plans, and manage exposure templates.  The pages here describe each entity and how to manage it, as well as detailing the associated properties.

For thoughts on how to organize your projects and targets, see [Project/Target Organization](organization.html).

{: .note}
Editing projects, targets, etc in the management UI uses a _modal editing_ approach (unlike the rest of the NINA UI).  You must click the Edit icon to enter edit mode, make your changes, and then Save or Cancel.  The management navigation trees will be locked against changes until you either Save or Cancel.  This is necessary to minimize database commits and ensure integrity.

## Navigation

The UI is organized using two navigation trees on the left: one for projects and targets, and one for exposure templates.  The trees work as you would expect: expand and collapse levels as needed, select items to show a detail view in the right panel.  You can also use the keyboard arrow keys to navigate the trees.

Each tree includes a top level folder named Profiles, and children of this node are the names of the profiles you currently have configured in the NINA Options tab.  All entities created for the plugin are unique to one profile since they will often depend on the characteristics of the associated equipment.

Be aware that some paste operations require that you select the appropriate level in the tree.  For example, to paste a project, you need to select a named profile under the Profiles folder (since projects must be immediate children of a profile).  The paste icon will only be enabled if the operation is appropriate.

Some changes within NINA will necessitate a refresh of the navigation trees.  For example, when you add a new NINA profile, you need to click the refresh button on the navigation trees to have the new profile name added.  If you remove a NINA profile, the same is true - plus you may [orphan](#orphaned-items) Projects or Exposure Templates.

### Icons
The following icons provide access to all management actions.

| Icon                                                                                               | Operation                            | Description                                                                                                                                                                                                                                                                                                   |
|:---------------------------------------------------------------------------------------------------|:-------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ![](../assets/images/edit-icon.png)                                                                | Edit                                 | Enter Edit mode.                                                                                                                                                                                                                                                                                              |
| ![](../assets/images/copy-icon.png)                                                                | Copy                                 | Copy the current item onto the clipboard in preparation for a paste (or move in the case of targets).                                                                                                                                                                                                         |
| ![](../assets/images/delete-icon.png)                                                              | Delete                               | Delete the current item.  A popup requests confirmation since deletes cannot be undone.  Deleting an item removes all subordinate items as well: all targets for a deleted project and all exposure plans for a deleted target.                                                                               |
| ![](../assets/images/export-icon.png)                                                              | Export                               | Export profiles.                                                                                                                                                                                                                                                                                              |
| ![](../assets/images/import-icon.png)                                                              | Import                               | Import profiles or targets.                                                                                                                                                                                                                                                                                   |
| ![](../assets/images/save-icon.png)                                                                | Save                                 | Save the current item (only enabled in Edit mode after changes have been made).                                                                                                                                                                                                                               |
| ![](../assets/images/cancel-icon.png)                                                              | Cancel                               | Cancel the current edit operation (only enabled in Edit mode).                                                                                                                                                                                                                                                |
| ![](../assets/images/add-icon.png)                                                                 | Add                                  | Add a new item (the type depends on the context).  New items are automatically saved, appear in the tree, and are selected for further action.                                                                                                                                                                |
| ![](../assets/images/paste-icon.png)                                                               | Paste                                | Paste a copy of an item from the clipboard.  The icon is only enabled when the clipboard contains an item of the appropriate type for the current context.  After pasting, the clipboard is cleared to prevent confusion later (except for copied Exposure Plans or Scoring Rule Weights which are retained). |
| ![](../assets/images/move-icon.png)                                                                | Move (target)                        | Move the target on the clipboard to the current project.  The icon is only enabled when the clipboard contains a target.  After pasting, the clipboard is cleared to prevent confusion later.                                                                                                                 |
| ![](../assets/images/checkmark-icon.png)                                                           | Active/Enabled                       | Indicates that the item is active/enabled.  See below.                                                                                                                                                                                                                                                        |
| ![](../assets/images/disabled-icon.png)                                                            | Inactive/Disabled                    | Indicates that the item is inactive/disabled.  See below.                                                                                                                                                                                                                                                     |
| ![](../assets/images/settings-icon.png)                                                            | Settings                             | Jump to the view/edit panel for the item.                                                                                                                                                                                                                                                                     |
| ![](../assets/images/external-link-icon.png)                                                       | Doc Link                             | Open the relevant documentation in a browser.                                                                                                                                                                                                                                                                 |
| ![](../assets/images/collapse-all-icon.png)                                                        | Collapse All                         | Collapse all nodes in the corresponding navigation tree.                                                                                                                                                                                                                                                      |
| ![](../assets/images/expand-all-icon.png)                                                          | Expand All                           | Expand all nodes in the corresponding navigation tree.                                                                                                                                                                                                                                                        |
| ![](../assets/images/eyedropper-inactive-icon.png)![](../assets/images/eyedropper-active-icon.png) | Color Projects/Targets               | Color projects and targets by active/inactive in the navigation tree (click to toggle).  See below.                                                                                                                                                                                                           |
| ![](../assets/images/showactive-inactive-icon.png)![](../assets/images/showactive-active-icon.png) | Display Projects/Targets Active Only | Display all projects and targets in the navigation tree or only those that are active (click to toggle).  See below.                                                                                                                                                                                          |
| ![](../assets/images/trigger-grading-icon.png)                                                     | Trigger Grading                      | Manually trigger grading on applicable pending images.  Applicable images depends on the usage context.                                                                                                                                                                                                       |
| ![](../assets/images/refresh-icon.png)                                                             | Refresh/Reset                        | Refresh/reload.  Most often needed for the navigation trees after adding or removing NINA profiles.  Also used to reset Scoring Rule Weights back to the defaults as well as reset target exposure plan completion.                                                                                           |
| ![](../assets/images/pause-icon.png)                                                               | Pause                                | Pause the Target Scheduler Container during imaging. See [pausing the container](../sequencer/container.html#pausing-the-container).                                                                                                                                                                          |
| ![](../assets/images/resume-icon.png)                                                              | Resume                               | Resume a paused Target Scheduler Container.                                                                                                                                                                                                                                                                   |


### Active/Enabled

Active/enabled implies that the item will be considered by the [Planning Engine](../concepts/planning-engine.html), otherwise it will be excluded.

A Target is active/enabled if:
* It belongs to a project that has State equal to Active
* The Enabled flag is true
* At least one of its exposure plans needs images (Percent Complete < 100)

A target with no exposure plans is considered inactive since it wouldn't be considered by the planner.

A Project is active/enabled if:
* The State is Active
* At least one of its Targets is active/enabled with at least one incomplete exposure plan.

A project with no targets is considered inactive since it wouldn't be considered by the planner.  Also, note that projects may show as active/enabled but not be scheduled if the project belongs to a NINA profile that isn't currently active.

### Orphaned Items

If you delete a NINA profile that had Projects or Exposure Templates attached to it or copy the Target Scheduler database to a new PC, then Projects and Exposure Templates become _orphaned_.  If so, you will see an item in the Profiles list named 'ORPHANED'.  If you select it, you'll be presented with a list of impacted items and can choose to either move or delete each one.
