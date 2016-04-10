todo.vim
--------

Even though I love Todoist, I often find myself creating todo.txt files because they're very flexible and easy to work with. Over the last few years, I've evolved a todo.txt file format, with syntax highlighting and a few keyboard shortcuts. — Edit

This filetype is automatically applied to files that have the filename pattern `*todo*.txt`.

### Concepts

**Categories**

Lines starting with `>>` mark the beginning of a category. These are groups of tasks that have whatever you want in common.

You can move with `[[`, `[]` to the beginning of a category backwards or forwards.  Also, `]]`, `][` moves to the end of each category (the last line).

**Markdown Categories**

Sometimes a category may just contain notes, and it's more useful to have it highlighted as markdown. Categories that have `##` following the `>>` and some option whitespace will be highlighted as markdown.

**Tasks**

Every line in the todo list is considered a task. A special symbol at the beginning of the list denotes the status of a task.

| Symbol | Meaning   | Keyboard Shortcut |
|:------:|-----------|-------------------|
|  `✓`   | completed | `Enter`           |
|  `✗`   | discarded | `Ctrl+Enter`      |
|  `→`   | next      | `Ctrl+N`          |
|  `⇨`   | soon      | `Ctrl+X`          |
|  `~`   | postponed |                   |

Using a keyboard shortcut on a task that already has a status will first remove that status. You will have to press again to assign a new status.

**Sub-Tasks**

Tasks can be indented to for sub-tasks. Though tasks at the beginning of the line don't have a delimiter, sub-tasks must have a `* ` preceded (a star followed by a space). The star would be replaced by the status symbol when operating with the keyboard shortcuts.

Status affects the way sub-tasks are displayed. A completed or discarded parent task will shade all sub-tasks, for example.

**Tags**

Words beginning with `@` within a task are considered tags and are shown in a different color.

**Highlights**

In addition to status, whole tasks can be highlighted by using a symbol at the beginning of the line, either before or after the status. These highlights supercede status-based formatting. You can find different meanings for these, depending on context.

| Symbol | Tentative Meaning          |
|:------:|----------------------------|
|  `+`   | added / positive           |
|  `-`   | removed / negative         |
|  `@`   | expanded below / reference |

