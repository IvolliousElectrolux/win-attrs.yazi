# win-attrs.yazi

A simple Yazi fetcher plugin to asynchronously retrieve Windows file attributes (RHSA: Read-only, Hidden, System, Archive).

## Features

- **Asynchronous**: Runs the Windows `attrib` command in the background to avoid blocking the UI.
- **Accurate**: Provides real Windows attributes that are sometimes missing from the standard Yazi `cha` data.
- **Cached**: Synchronizes attribute data between background fetchers and the UI thread for real-time display.

## Installation

1. Copy the `win-attrs.yazi` folder to your Yazi plugins directory.
2. Add the following to your `yazi.toml`:

```toml
[[plugin.prepend_fetchers]]
id   = "win-attrs"
url = "*"
run  = "win-attrs"
```

## Usage

You can use the attributes in other plugins (like `yatline.yazi`) by requiring `win-attrs`:

```lua
local win_attrs = require("win-attrs")
local attrs = win_attrs.get(hovered.url)
-- attrs will be a table: { "R", "H", "S", "A" } or { ".", ".", ".", "." }
```

## License

MIT

