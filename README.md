# GDSh utils

Portable shell utilities for [GDSh](https://github.com/brohd11/godot-gdsh.git)
consoles. They have no editor dependency, so a runtime debug console can use the
same commands as Editor Console.

## Loading

```gdscript
var ctx = GDSh.Context.new()
# Hidden: callable by name (`count`) or through the `utils` namespace (`utils count`).
ctx.load("res://addons/addon_lib/gdsh_lib/utils", true)
```

`GDSh.Load.load_directory(path)` returns the scope dictionary instead. The commands
are non-discoverable, so `hidden` lists only `utils`; `utils ` completes them.

## Commands

| Command | Use |
| --- | --- |
| `cat` | Print a file (argument or first stdin line) |
| `check` | Validate that scripts or scenes load |
| `class` | Introspect an engine or global class |
| `count` | Count stdin lines, words, or characters |
| `find` | Find project files by name or glob |
| `grep` | Keep matching stdin lines |
| `head` / `tail` | First or last N stdin lines |
| `ls` | List a directory, optionally recursive |
| `math` | Evaluate an expression (GDSh `expr`) |
| `mkdir` / `mv` | Create directories, move files |
| `open` | Reveal a path in the OS file manager (desktop) |
| `pwd` / `realpath` | Working directory and path conversion |
| `scan` | Search scripts for uncommented matches |
| `strip_edges` | Strip stdin whitespace |
| `trash` | Move paths to the OS trash (desktop) |
| `xargs` | Append stdin words to a command |

Run `<command> --help` for flags.

## Host hooks

Commands that list or change project files use `GDSh.Utils` host hooks from
`ctx.host_data`. Both are optional:

- `"file_paths"`: `Callable(directories:bool) -> PackedStringArray`, for a cached
  file listing (`ls --recursive`, `find`, `scan`). The default walks `res://`.
- `"filesystem_changed"`: `Callable()`, called after `mkdir`, `mv`, and `trash`,
  for example to rescan the editor FileSystem dock.

## Exporting

`manifest.gd` preloads every command for use with [PluginExporter](https://github.com/brohd11/Godot-Plugin-Exporter)

## Install

Download the release and place the contents in the addons folder.

I use [gdaddon](https://github.com/brohd11/gdaddon) to manage the addon.
```
cd ~/your/project/
gdaddon install brohd11/godot-gdsh-lib-utils
```

## Validation

```sh
python3 tests/gdsh_lib/run_headless.py --godot godot --export
```
