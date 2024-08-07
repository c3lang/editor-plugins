# VSCode C3 Extension (Syntax Highlighting and LSP)

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

- *Enable*: `c3lspclient.lsp.enable` Enables or disables the connection with the Language server.
- *Binary path*: `c3lspclient.lsp.path` The path to the **c3-lsp** binary. Mandatory or extension will fail to start.
- *Send crash reports*: `c3lspclient.lsp.sendCrashReports` Enables sending crash reports to a server. Will help debug possible bugs. Disabled by default.

## Known Issues

Despite the configurations, the integration with the LSP is not working.

## Release Notes


### 0.0.1

Initial release.

### 0.0.3

- Improved syntax highlighting.
- Some code snippets.

---

