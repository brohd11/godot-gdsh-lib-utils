extends RefCounted
## gdsh_lib utils runtime checks, driven by runtime_test.gd (headless and editor console `test`).

const Sh = preload("res://addons/_lib/gdsh/_ns/gd_sh.gd")
const Manifest = preload("res://addons/_lib/gdsh_lib/utils/src/manifest.gd")
const UTILS = "res://addons/_lib/gdsh_lib/utils/src"
const FIXTURES = "res://addons/_lib/gdsh_lib/utils/_export_ignore/test/fixtures"
var checks = 0
var failures = 0
var report:Array[String] = []


func run_sync():
	_test_loading()
	_test_streams()
	_test_str()
	_test_paths()
	_test_path_completion()
	_test_filesystem()
	_test_class()


func run_frames() -> void:
	pass


func finish() -> Array[String]:
	report.append("GDSh utils: %d checks, %d failures" % [checks, failures])
	return report


## The running tree: the headless runner's SceneTree or the editor's.
func _tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


func check(condition:bool, label:String):
	checks += 1
	if not condition:
		failures += 1
		report.append("FAIL: " + label)


func equal(actual, expected, label:String):
	check(actual == expected, "%s (expected %s, got %s)" % [label, str(expected), str(actual)])


func session() -> Sh.Context:
	var ctx = Sh.Context.new()
	ctx.load(UTILS, true)
	return ctx


func run(text:String, stdin:="", ctx:Sh.Context=null) -> Sh.Context:
	var result = Sh.Context.new_ctx("test", ctx if ctx != null else session())
	result.stdin = stdin
	Sh.Execute.execute_command_multiline(text, result)
	return result


func out(text:String, stdin:="", ctx:Sh.Context=null) -> String:
	return run(text, stdin, ctx).stdout.strip_edges()


func _test_loading():
	var scopes = Sh.Load.load_directory(UTILS)
	equal(scopes.size(), Manifest.COMMANDS.size(), "directory loads exactly the manifest commands")
	check(not scopes.has("manifest"), "manifest.gd is not loaded as a command")
	for script in Manifest.COMMANDS:
		check(scopes.has(script.get_command_name()), "manifest command loads: " + script.get_command_name())
	var ctx = session()
	check(not Sh.Completion.new("", ctx).get_completions().has("cat"), "utils load as hidden commands")
	var hidden_choices = Sh.Completion.new("hidden ", ctx).get_completions()
	check(hidden_choices.has("utils") and not hidden_choices.has("grep"), "hidden lists the utils namespace, not its children")
	check(Sh.Completion.new("utils ", ctx).get_completions().has("grep"), "utils namespace lists its commands")
	equal(out("utils count", "a\nb", ctx), "2", "utils namespace routes to a command")


func _test_streams():
	var lines = "alpha\nbeta\ngamma\n"
	equal(out("count", lines), "3", "count lines")
	equal(out("count --words", "a b\nc"), "3", "count words")
	equal(out("head 2", lines), "alpha\nbeta", "head")
	equal(out("tail 1", lines), "gamma", "tail")
	equal(out("grep et", lines), "beta", "grep substring")
	equal(out("grep --regex ^g", lines), "gamma", "grep regex")
	equal(out("grep -iv ALPHA", lines), "beta\ngamma", "grep groups short flags")
	var bad_short = run("grep -ix a", lines)
	check(bad_short.exit_code != 0 and bad_short.stderr.contains("Unrecognized flag: -x"), "unknown short flag letter errors")
	check(run("grep --help").stdout.contains("-i, --ignore-case"), "help lists short forms")
	var after_short = Sh.Completion.new("grep -i ", session()).get_completions()
	check(not after_short.has("--ignore-case") and after_short.has("--invert"), "completion hides flags given in short form")
	equal(out("math 2 + 3"), "5", "math")
	equal(out("xargs echo", "one 'two words'\nthree"), "one two words three", "xargs keeps quoted words")
	equal(out("echo a | hidden utils count"), "1", "utils route through hidden and their namespace")


func _test_str():
	var children = Sh.Load.load_directory(UTILS.path_join("str"), true)
	equal(children.size(), Manifest.STR_COMMANDS.size(), "manifest preloads every str subcommand")
	var ctx = session()
	check(not Sh.Completion.new("hidden ", ctx).get_completions().has("str"), "str stays under the utils namespace")
	check(Sh.Completion.new("utils ", ctx).get_completions().has("str"), "utils lists str")
	var ops = Sh.Completion.new("str ", ctx).get_completions()
	check(ops.has("basedir") and ops.has("strip_edges") and not ops.has("str_util") and not ops.has("match_base"), "str completes its ops, not its shared scripts")
	check(not Sh.Completion.new("", ctx).get_completions().has("strip_edges"), "strip_edges moved under str")

	equal(out("str basedir res://a/b.gd"), "res://a", "basedir")
	equal(out("str file res://a/b.gd"), "b.gd", "file")
	equal(out("str basename res://a/b.gd"), "res://a/b", "basename")
	equal(out("str extension res://a/b.gd"), "gd", "extension")
	equal(out("str join c.gd res://a"), "res://a/c.gd", "join")
	equal(out("str file", "res://a/x.gd\nres://b/y.tscn\n"), "x.gd\ny.tscn", "ops map stdin lines")
	equal(run("str extension", "a\nb.gd").stdout, "\ngd\n", "empty results keep lines aligned")

	var paths = "res://a.gd\nuser://b.gd\nres://c.tscn\n"
	equal(out("str ends_with .gd", paths), "res://a.gd\nuser://b.gd", "ends_with filters stdin")
	equal(out("str begins_with res:// | str file", paths), "a.gd\nc.tscn", "predicates pipe into ops")
	equal(run("str ends_with .png", paths).exit_code, 1, "no match fails")
	var bool_hit = run("str contains -b foo xfoo")
	check(bool_hit.exit_code == 0 and bool_hit.stdout == "", "--bool prints nothing on a match")
	equal(run("str contains --bool foo bar").exit_code, 1, "--bool fails without a match")
	equal(out("str contains -i FOO xfoo"), "xfoo", "--ignore-case")
	equal(run("str ends_with -bi .GD a.gd").exit_code, 0, "match short flags group")
	equal(out("if str begins_with -b res:// res://x { echo local } else { echo other }"), "local", "predicates drive if")
	equal(out('str begins_with "-x" "-xy"'), "-xy", "quoted dash words are literal")

	equal(out("str trim_prefix res:// res://a/b"), "a/b", "trim_prefix")
	equal(out("str trim_suffix .gd a.gd"), "a", "trim_suffix")
	equal(out("str replace / . a/b/c"), "a.b.c", "replace")
	equal(out("str replace -i A x aAa"), "xxx", "replace --ignore-case")
	equal(out("str upper abc"), "ABC", "upper")
	equal(out("str lower ABC"), "abc", "lower")
	equal(out("str slice / 1 a/b/c"), "b", "slice")
	equal(out("str slice / -1 a/b/c"), "c", "slice negative index")
	equal(run("str slice / 5 a/b").stdout, "\n", "slice out of range prints an empty line")
	var bad_index = run("str slice / x a/b")
	check(bad_index.exit_code != 0 and bad_index.stderr.contains("Index must be an integer"), "slice rejects a non-int index")
	equal(out("str length hello"), "5", "length")
	equal(out('str length ""'), "0", "an empty text argument is input")
	equal(out("str strip_edges", "  padded  "), "padded", "strip_edges")
	equal(out("str strip_edges", "  a  \n b "), "a\nb", "strip_edges maps lines")
	equal(run("str strip_edges --left", " a ").stdout, "a \n", "--left keeps trailing whitespace")
	var no_input = run("str upper")
	check(no_input.exit_code != 0 and no_input.stderr.contains("No input"), "ops without input fail")


func _test_paths():
	var ctx = session()
	ctx.cwd = FIXTURES
	var fixture = Node.new()
	fixture.name = "GDShRealpathCompletion"
	_tree().root.add_child(fixture)
	var child = Node.new()
	child.name = "NodeOnly"
	fixture.add_child(child)
	ctx.cwn = str(fixture.get_path())
	var choices = Sh.Completion.new("realpath ./", ctx).get_completions()
	check(choices.has("sample.txt") and choices.has("nested"), "realpath completes files and directories")
	check(not choices.has("NodeOnly"), "realpath completion excludes nodes")
	choices = Sh.Completion.new('realpath "./nested/', ctx).get_completions()
	check(choices.has("inner.txt"), "realpath completes quoted directory paths")
	if choices.has("inner.txt"):
		equal(choices["inner.txt"][Sh.Options.Keys.METADATA][Sh.Options.Keys.INSERT], '"./nested/inner.txt"', "realpath preserves quoting")
	fixture.free()
	var listing = out("ls", "", ctx).split("\n")
	check(listing.has("sample.txt") and listing.has("nested/"), "ls lists files and directories: " + str(listing))
	check(out("ls --recursive", "", ctx).split("\n").has("nested/inner.txt"), "ls --recursive walks res:// by default")
	check(out("ls -r", "", ctx).split("\n").has("nested/inner.txt"), "ls -r is --recursive")
	check(out("find inner", "", ctx).split("\n").has(FIXTURES + "/nested/inner.txt"), "find matches file names")
	equal(out("cat sample.txt", "", ctx), "sample text", "cat resolves paths from cwd")
	ctx.host_data["file_paths"] = func(directories): return PackedStringArray([] if directories else [FIXTURES + "/cached.txt"])
	equal(out("find cached", "", ctx), FIXTURES + "/cached.txt", "find uses the host file_paths hook")


func _test_path_completion():
	var ctx = session()
	ctx.cwd = FIXTURES
	for command in ["cat", "check", "mkdir", "mv", "trash", "ls", "open", "realpath"]:
		for prefix in ["", "utils "]:
			var text = prefix + command + " ./"
			var choices = Sh.Completion.new(text, ctx).get_completions()
			check(choices.has("sample.txt") and choices.has("nested"), "utility completes files and directories: " + text)
	for text in ["mv ./sample.txt ./", "utils mv ./sample.txt ./", "trash ./sample.txt ./nested/inner.txt ./"]:
		check(Sh.Completion.new(text, ctx).get_completions().has("sample.txt"), "later path argument completes: " + text)
	var quoted = Sh.Completion.new('cat "./nested/', ctx).get_completions()
	check(quoted.has("inner.txt"), "cat completes quoted paths")
	if quoted.has("inner.txt"):
		equal(quoted["inner.txt"][Sh.Options.Keys.METADATA][Sh.Options.Keys.INSERT], '"./nested/inner.txt"', "cat preserves path quoting")
	for text in ["scan ./", "scan -i ./", "find ./", "grep ./", "head ./", "tail ./"]:
		check(not Sh.Completion.new(text, ctx).get_completions().has("sample.txt"), "non-path argument excludes filesystem suggestions: " + text)
	for text in ["scan pattern ./", "scan pattern ./sample.txt ./", "scan --prints ./", "scan -p ./", "scan -pi ./", "utils scan pattern ./"]:
		check(Sh.Completion.new(text, ctx).get_completions().has("sample.txt"), "scan completes path arguments: " + text)
	var flags = Sh.Completion.new("scan -i pattern ", ctx).get_completions()
	check(flags.has("--regex") and not flags.has("--ignore-case"), "scan retains flags after its pattern and hides consumed flags")
	flags = Sh.Completion.new("scan ./", ctx).get_completions()
	check(flags.has("--prints"), "scan retains flags while typing a pattern")


func _test_filesystem():
	var root = "user://gdsh_lib_filesystem_test"
	for path in [root + "/b", root + "/a", root]:
		DirAccess.remove_absolute(path)
	var ctx = session()
	var changes = [0]
	ctx.host_data["filesystem_changed"] = func(): changes[0] += 1
	equal(run("mkdir " + root + "/a", "", ctx).exit_code, 0, "mkdir succeeds")
	check(DirAccess.dir_exists_absolute(root + "/a"), "mkdir creates the directory")
	equal(run("mv " + root + "/a " + root + "/b", "", ctx).exit_code, 0, "mv succeeds")
	check(DirAccess.dir_exists_absolute(root + "/b") and not DirAccess.dir_exists_absolute(root + "/a"), "mv renames the directory")
	equal(changes[0], 2, "mkdir and mv notify the host")
	equal(run("mkdir " + root + "/c").exit_code, 0, "file commands work without a host hook")
	for path in [root + "/b", root + "/c", root]:
		DirAccess.remove_absolute(path)


func _test_class():
	var result = run("class Node")
	check(result.exit_code == 0 and result.stdout.contains("Node[/color] : ") and result.stdout.contains("methods ("), "class summarizes an engine class")
	check(out("class --inherits Node2D").contains("CanvasItem"), "class prints the inheritance chain")
	equal(run("class GDSh").exit_code, 0, "class resolves global script classes")
	equal(run("class NoSuchClassAnywhere").exit_code, 1, "unknown class fails")
