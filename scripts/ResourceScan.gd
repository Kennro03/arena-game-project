class_name ResourceScan
extends RefCounted

## Loads every .tres/.res resource directly inside `dir` (not recursive).
## Safe when the folder doesn't exist, and works in exported builds
## (ResourceLoader.list_directory reports original names, not .remap files).
static func load_all(dir: String) -> Array[Resource]:
	var results: Array[Resource] = []
	if not dir.ends_with("/"):
		dir += "/"
	if not DirAccess.dir_exists_absolute(dir):
		push_warning("ResourceScan: folder not found: " + dir)
		return results
	for file_name in ResourceLoader.list_directory(dir):
		if file_name.ends_with("/"):
			continue # subfolder
		if file_name.get_extension() not in ["tres", "res"]:
			continue
		var res := load(dir + file_name)
		if res != null:
			results.append(res)
	return results
