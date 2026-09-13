extends "res://addons/addon_lib/gdsh/command_base.gd"
## Namespace for the portable utilities in this directory. Children are discovered from
## the sibling `name/name.gd` directories, so they are listed even though each is
## non-discoverable at the top level.

const _HELP = "Portable utilities, also accessible directly by name."


static func get_command_name() -> String:
	return "utils"


static func get_self_command_data() -> Dictionary:
	return _command_data({&"help": _HELP})


func _execute(ctx:Context):
	ctx.append_output(get_help_string(true))
	return ExitCode.OK
