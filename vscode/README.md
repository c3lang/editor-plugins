# C3 Language Support for VSCode

This is the VSCode extension from the 'Editor Plugins' repo of C3 Programming Language focused on syntax highlighting and code snippets.  

There is another [extension](https://marketplace.visualstudio.com/items?itemName=tonios2.c3-vscode) on the VSCode marketplace which gives the support to the [Language Server for C3 Language](https://github.com/pherrymason/c3-lsp.git). 

For now, you need to install both extensions to get the syntax highlighting and the LSP.

## Features

Features:

- Syntax highlighting
- Code snippets

## Requirements

If you want to install the LSP, follow the instructions on: 

https://github.com/pherrymason/c3-lsp/wiki/Integration-with-editors


## Extension Settings

- *Enable*: `c3.lsp.enable` Enables or disables the connection with the Language server.
- *Binary path*: `c3.lsp.path` The path to the **c3-lsp** binary. Mandatory or extension will fail to start.
- *Send crash reports*: `c3.lsp.sendCrashReports` Enables sending crash reports to a server. Will help debug possible bugs. Disabled by default.
- *Log Path*: `c3.lsp.log.path` Saves log to specified file.
- *C3 LSP Version*: `c3.lsp.version` Specify C3 language version. If omited, LSP will use the last version it supports.

## Known Issues

Despite the configurations, the integration with the LSP depends on the installation described in https://github.com/pherrymason/c3-lsp/wiki/Integration-with-editors.

## Release Notes


### 0.0.1

- Initial release.

### 0.0.2

- Improvements.

### 0.0.3

- Improved syntax highlighting.
- Added some code snippets.

---

