extends Node

const SAVE_PATH := "user://save.json"
const DEFAULT_LEVEL := "res://levels/level_1.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.02,0.08,0.15,1.00))


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func create_save(level_path: String = DEFAULT_LEVEL) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"level": level_path}))
	file.close()


func get_save_level() -> String:
	if not has_save():
		return DEFAULT_LEVEL
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) == TYPE_DICTIONARY and data.has("level"):
		return data["level"]
	return DEFAULT_LEVEL


func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
