# C3 setup for Pragtical

## Syntax highlighting

Download [language_c3.lua](https://github.com/pragtical/plugins/blob/master/plugins/language_c3.lua) via Pragtical Plugin Manager or manually.

## Go-To / Search definition

Download [_find](https://github.com/0riginaln0/_find) plugin.

It covers a big margin of go-to & search definition actions.


## LSP

Download [lsp](https://github.com/pragtical/lsp) plugin.

Config example for adding [c3_ls](https://github.com/ManuLinares/c3_ls).

`.config/pragtical/init.lua`
```lua
-- ...

local lsp = require "plugins.lsp"

lsp.add_server {
  name = "c3_ls",
  language = "C3",
  file_patterns = { "%.c3$", "%.c3i$" },
  command = {"c3_ls"},
  transport = "stdio",
}
```

## Formatter

Download [formatter](https://github.com/pragtical/formatter) plugin.

Set it up following its [contributing a formatter](https://github.com/pragtical/formatter#contributing-a-formatter) `README.md` section.

(If you succeed, paste code snippet here)
