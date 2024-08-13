# C3 Language Support for VSCode

This is the VSCode extension from the 'Editor Plugins' repo of C3 Programming Language focused on syntax highlighting and code snippets.  

This extension also supports the [Language Server for C3 Language](https://github.com/pherrymason/c3-lsp.git). 

## Features

Features:

- Syntax highlighting
- Code snippets
- Supports the C3 Language LSP

## Requirements

If you want to install the LSP, follow the instructions on: 

https://github.com/pherrymason/c3-lsp/wiki/Integration-with-editors

## Known Issues

The LSP support **must be enabled by the user**. The extension will look for the LSP binaries in the extension folder, e.g: 
- MacOS: "/.vscode/extensions/c3language/c3-lsp-macos".
- Linux: "˜/.vscode/extensions/c3language/c3-lsp-linux".
- Windows: "%USERPROFILE%\.vscode\extensions\c3language\c3-lsp-win.exe".

If the binary is not present, you will get an error. So, remember to copy the LSP binary to the extension folder or
set the `c3.lsp.path`.

After configuring the LSP => disable the extension => restart extensions => enable it again.

## Extension Settings

- *Enable*: `c3.lsp.enable` Enables or disables the connection with the Language server.
- *Binary path*: `c3.lsp.path` The path to the **c3-lsp** binary. Mandatory or extension will fail to start.
- *Send crash reports*: `c3.lsp.sendCrashReports` Enables sending crash reports to a server. Will help debug possible bugs. Disabled by default.
- *Log Path*: `c3.lsp.log.path` Saves log to specified file.
- *C3 LSP Version*: `c3.lsp.version` Specify C3 language version. If omited, LSP will use the last version it supports.


## Release Notes

### 0.0.1

- Initial release.

### 0.0.2

- Improvements.

### 0.0.3

- Improved syntax highlighting.
- Added some code snippets.
- Added Support to LSP

---

