extends Node
## Autoload "Progress": the game's single ProgressStore at user://save.json.

var store := ProgressStore.new("user://save.json")


func _ready() -> void:
	store.load_or_default()
