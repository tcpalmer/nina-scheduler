---
layout: default
title: Project / Target Management
nav_order: 6
has_children: true
---

# Project and Target Management

The plugin provides a UI to manage your projects, targets, and exposure plans.  Through the interface, you can add new projects and targets, add and update exposure plans, and manage exposure templates.  The pages here describe each entity and how to manage it, as well as detailing the associated properties.

{: .note}
Editing projects, targets, etc in the management UI uses a _modal editing_ approach (unlike the rest of the NINA UI).  You must click the Edit icon to enter edit mode, make your changes, and then Save or Cancel.  This is necessary to minimize database commits and ensure integrity.

## Navigation

The UI is organized using two navigation trees on the left: one for projects and targets, and one for exposure templates.  The trees work as you would expect: expand and collapse levels as needed, select items to show a detail view in the right panel.  You can also use the keyboard arrow keys to navigate the trees.

Each tree includes a top level folder named Profiles, and children of this node are the names of the profiles you currently have configured in the NINA Options tab.  All entities created for the plugin are unique to one profile since they will often depend on the characteristics of the associated equipment.

Be aware that some paste operations require that you select the appropriate level in the tree.  For example, to paste a project, you need to select a named profile under the Profiles folder (since projects must be immediate children of a profile).  The paste icon will only be enabled if the operation is appropriate.


### Icons
The following icons provide access to all management actions.

|Icon|Operation|Description|
|:--|:--|:--|
|![](../assets/images/edit-icon.png)|Edit|Enter Edit mode.|
|![](../assets/images/copy-icon.png)|Copy|Copy the current item onto the clipboard.|
|![](../assets/images/delete-icon.png)|Delete|Delete the current item.  A popup requests confirmation since deletes cannot be undone.  Deleting an item removes all subordinate items as well: all targets for a deleted project and all exposure plans for a deleted target.|
|![](../assets/images/import-icon.png)|Import|Import a target.|
|![](../assets/images/save-icon.png)|Save|Save the current item (only enabled in Edit mode after changes have been made).|
|![](../assets/images/cancel-icon.png)|Cancel|Cancel the current edit operation (only enabled in Edit mode).|
|![](../assets/images/add-icon.png)|Add|Add a new item (the type depends on the context).  New items are automatically saved, appear in the tree, and are selected for further action.|
|![](../assets/images/paste-icon.png)|Paste|Paste a copy of an item from the clipboard.  The icon is only enabled when the clipboard contains an item of the appropriate type for the current context.  After pasting, the clipboard is cleared to prevent confusion later.|
|![](../assets/images/settings-icon.png)|Settings|Jump to the view/edit panel for the item.|
|![](../assets/images/external-link-icon.png)|Doc Link|Open the relevant documentation in a browser.|
|![](../assets/images/expand-all-icon.png)|Expand All|Expand all nodes in the corresponding navigation tree.|
|![](../assets/images/collapse-all-icon.png)|Collapse All|Collapse all nodes in the corresponding navigation tree.|

See the pages linked below for details on managing each entity type.
