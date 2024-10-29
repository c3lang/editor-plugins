# Sublime Text Package

Features:
- Full syntax highlighting
- Build tools with support for `build`, `test`, `benchmark`, `clean` anf `run`. The `c3c` executable must be in the PATH for this to work. Build errors are parsed.

To use it put this ([../sublime-build](../sublime-text)) directory into your
`Packages/User/` folder and rename it to e.g. `c3`. The `Packages/User/`
directory has the following paths:

- Linux: `~/.config/sublime-text/Packages/User/`
- MacOS: `~/Library/Application Support/Sublime Text/Packages/User/`
- Windows: `%APPDATA%\Roaming\Sublime Text\Packages\User\` (`C:\Users\<username>\AppData\Roaming\Sublime Text\Packages\User\`)

## Contributing

[./C3.sublime-build](./C3.sublime-build) adds C3's build system integration, see
[Sublime Text Build System Reference](https://www.sublimetext.com/docs/build_systems.html)


# Toggle Comment Fix for C3 Plugin in Sublime Text
There is a known issue with the C3 plugin for Sublime Text where the "Toggle Comment" feature doesn't function properly. Until this issue is resolved, you can use this simple plugin to enable commenting of single-line or multi-line code in Sublime Text for C3 files.

Installation Guide
Step 1: Create the Plugin
Open Sublime Text.

Navigate to Tools > Developer > New Plugin....

Replace the default code with the code from file c3_toggle_comment.py

Save the file as c3_toggle_comment.py in the Packages/User directory.

Step 2: Set Up Key Binding
Press Ctrl+Shift+P (or Cmd+Shift+P on macOS) to open the Command Palette.

Type Preferences: Key Bindings and select it.

In the user key bindings file that opens, add the following code inside the array brackets (make sure to add commas if necessary):

{
    "keys": ["ctrl+/"],
    "command": "c3_toggle_comment",
    "context": [
        { "key": "selector", "operator": "equal", "operand": "source.c3" }
    ]
}

How to Use
Toggle Comment: Open a C3 file and select the lines you want to comment or uncomment.
Press Ctrl+/ to toggle comments on the selected lines.
Additional Information
This plugin is a temporary workaround until the issue with the original C3 plugin is fixed.
Feel free to customize the key binding and the plugin code to suit your needs.
Cheers!