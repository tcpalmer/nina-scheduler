---
layout: default
title: Advanced Topics
nav_order: 11
---

# Advanced Topics

## Database Access and Updates

The TS [database](technical-details.html#database) has a simple structure and if you're adept at databases and SQL, you can read it or update it yourself.

[DB Browser for SQLite](https://sqlitebrowser.org/) is an excellent tool to view and update the database.  It also has a [command line interface](https://github.com/sqlitebrowser/sqlitebrowser/wiki/Command-Line-Interface) so you can automate changes.

Some examples:
- Create your own application to view the contents of the database and report on project/target status.
- Import projects/targets from some external source.
- Clear or manage progress on target [exposure plans](target-management/exposure-plans.html).
- Change the accepted/rejected status of graded images.

{: .note }
You should make a copy of the database before making changes.  Also, it's best to make updates while NINA isn't running.  However, you _can_ update it live and TS will see the changes the next time the [planning engine](concepts/planning-engine.html) is called.
