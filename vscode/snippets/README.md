# vscode-euphoria

## Snippets

Code snippets are templates that make it easier to enter repeating code patterns, such as loops or conditional statements. [Snippets in Visual Studio Code](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_creating-your-own-snippets) support _substring matching_ so you can type `pf` for `public-function`, etc. Most snippets have predefined breakpoints that can be navigated using the `Tab` key. For example, typing `if[Tab]` will give a complete `if` statement with the cursor between `if` and `then`, and then pressing `Tab` again will move the cursor to the body of the `if` statement.

### Branching statements

- `if`
  - `else`
  - `elsif`
- `ifdef`
  - `elsedef`
  - `elsifdef`
- `switch`
  - `case`
  - `case-else`
- `switch-with-fallthru`

### Looping statements

- `while`
- `while-with-entry`
- `loop`
- `loop-with-entry`
- `for`
- `for-by`

### Declaration statements

- `constant`
- `enum`
- `enum-type`

### Routine statements

- `function`
- `procedure`
- `type`

### Scoped variations

**public**

- `public-constant`
- `public-enum`
- `public-enum-type`
- `public-function`
- `public-procedure`
- `public-type`

**export**

- `export-constant`
- `export-enum`
- `export-enum-type`
- `export-function`
- `export-procedure`
- `export-type`

**global**

- `global-constant`
- `global-enum`
- `global-enum-type`
- `global-function`
- `global-procedure`
- `global-type`

