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
