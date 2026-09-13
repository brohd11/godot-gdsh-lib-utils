extends RefCounted
## Preloads every command in this directory, so exporters that follow preloads include
## them. GDSh.Load.load_directory skips this file. Load the commands with
## GDSh.Load.load_directory(Manifest.resource_path.get_base_dir()).

const COMMANDS = [
	preload("res://addons/addon_lib/gdsh_lib/utils/utils.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/cat/cat.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/check/check.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/class/class.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/count/count.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/find/find.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/grep/grep.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/head/head.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/ls/ls.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/math/math.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/mkdir/mkdir.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/mv/mv.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/open/open.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/pwd/pwd.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/realpath/realpath.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/scan/scan.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/strip_edges/strip_edges.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/tail/tail.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/trash/trash.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/xargs/xargs.gd"),
]
