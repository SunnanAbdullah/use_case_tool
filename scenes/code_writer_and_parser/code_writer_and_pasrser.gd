class_name CodeParser extends Window


@onready var code_edit: CodeEdit = $CodeEdit

var use_case_array : Array = [];
var actor_array : Array = [];
var connection_array : Array = [];


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	for i in code_edit.get_line_count():
		var line_text = code_edit.get_line(i)
		print("Line %d: %s" % [i + 1, line_text])
		parse2(line_text)
		#tokenizer(line_text)


func tokenizer(line: String):
	var tokens_array = line.split(" ")
	for token in tokens_array :
		if not token.is_empty() :
			print("tokens : " + token)


func parse2(line: String) -> void:
	line = line.strip_edges()  # Trim leading/trailing whitespace

	# Regex for actor
	var actor_regex = RegEx.new()
	actor_regex.compile(r"^create\s+actor\s*\(\s*\"(.+)\"\s*\)\s*;$")

	# Regex for usecase
	var usecase_regex = RegEx.new()
	usecase_regex.compile(r"^create\s+usecase\s*\(\s*\"(.+)\"\s*\)\s*;$")

	# Regex for connection
	var connection_regex = RegEx.new()
	connection_regex.compile(r'^create\s+connection\s+oftype\s*\(\s*\"(.+)\"\s*\)\s+between\s*\(\s*\"(.+)\"\s*\)\s+and\s*\(\s*\"(.+)\"\s*\)\s*;$')

	# Actor
	var result = actor_regex.search(line)
	if result != null:
		var name = result.get_string(1)
		actor_array.push_back(name)
		print("Creating actor:", name)
		return

	# Usecase
	result = usecase_regex.search(line)
	if result != null:
		var name = result.get_string(1)
		use_case_array.push_back(name)
		print("Creating usecase:", name)
		return

	# Connection
	result = connection_regex.search(line)
	if result != null:
		var connection_type = result.get_string(1)
		var from_node = result.get_string(2)
		var to_node = result.get_string(3)
		print((actor_array.has(from_node) or use_case_array.has(from_node)))
		if (actor_array.has(from_node) or use_case_array.has(from_node)) and (actor_array.has(to_node) or use_case_array.has(to_node)) :
			print("Creating connection of type:", connection_type, "between:", from_node, "and", to_node)
		return

	# Syntax error
	print("Syntax error:", line)



func _on_close_requested() -> void:
	queue_free()
