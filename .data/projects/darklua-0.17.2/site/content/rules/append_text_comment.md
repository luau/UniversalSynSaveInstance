---
description: Append a comment at the start or end of a file
added_in: "0.12.0"
parameters:
  - name: text
    type: string
    description: The string to use inside the comment (required if `file` is not defined)
  - name: file
    type: string
    description: A path to a file to be used as the comment content (required if `text` is not defined)
  - name: location
    default: start
    type: '"start" or "end"'
    description: The location where to add the comment
examples:
  - rules: "[{ rule: 'append_text_comment', text: '!native' }]"
    content: print('Print from module')
  - rules: "[{ rule: 'append_text_comment', text: 'hello!', location: 'end' }]"
    content: print('Print from module')
---

Use this rule to automatically insert a comment at the start or end of a file. This rule can be useful if you want to insert your license in each file.

**Note:** make sure to avoid using the `remove_comments` rule _after_ this rule in the process sequence, otherwise you will be removing your brand new comment.
