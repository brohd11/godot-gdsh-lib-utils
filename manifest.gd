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
	preload("res://addons/addon_lib/gdsh_lib/utils/str/str.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/tail/tail.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/trash/trash.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/xargs/xargs.gd"),
]

## Subcommands of the `str` namespace. Kept apart from COMMANDS, which mirrors the
## top-level load; load_directory finds these through str.gd.
const STR_COMMANDS = [
	preload("res://addons/addon_lib/gdsh_lib/utils/str/basedir/basedir.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/basename/basename.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/begins_with/begins_with.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/contains/contains.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/ends_with/ends_with.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/extension/extension.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/file/file.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/join/join.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/length/length.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/lower/lower.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/replace/replace.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/slice/slice.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/strip_edges/strip_edges.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/trim_prefix/trim_prefix.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/trim_suffix/trim_suffix.gd"),
	preload("res://addons/addon_lib/gdsh_lib/utils/str/upper/upper.gd"),
]
