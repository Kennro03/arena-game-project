extends Node
class_name name_registry

static var _name_lists: Dictionary = {}  # key -> Array[String]

static var _registry: Dictionary = {
	"stickman": "res://ressources/Data/stickman_names.txt",
	"slime": "",
}

static func get_random_name(list_key: String) -> String:
	_ensure_loaded(list_key)
	var list := _name_lists.get(list_key, []) as Array
	if list.is_empty():
		printerr("NameRegistry: no names found for key '%s'" % list_key)
		return "Unknown"
	return list.pick_random()

static func _ensure_loaded(list_key: String) -> void:
	if _name_lists.has(list_key):
		return
	
	var path: String = _registry.get(list_key, "")
	if path == "":
		printerr("NameRegistry: no file registered for key '%s'" % list_key)
		_name_lists[list_key] = []
		return
	
	var names: Array[String] = []
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line := file.get_line().strip_edges()
			if line != "":
				names.append(line)
		file.close()
	else:
		printerr("NameRegistry: could not open file '%s'" % path)
	
	_name_lists[list_key] = names
