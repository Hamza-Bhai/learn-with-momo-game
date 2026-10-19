extends Node
## Loads all learning content from res://data. Autoload name: ContentDB.

const CATEGORIES_PATH := "res://data/categories.json"
const ITEMS_DIR := "res://data/items/%s.json"
const PHRASES_PATH := "res://data/phrases.json"

## When true, items() hides items whose image or voice files are missing,
## so a missing asset never crashes a round. Tests turn this off.
var require_assets := true

var _categories: Array = []
var _items_by_category: Dictionary = {}
var _items_by_id: Dictionary = {}
var _phrases: Dictionary = {}


func _ready() -> void:
	_categories = _read_json(CATEGORIES_PATH, [])
	for c in _categories:
		var list: Array = _read_json(ITEMS_DIR % c.id, [])
		_items_by_category[c.id] = list
		for it in list:
			_items_by_id[it.id] = it
	_phrases = _read_json(PHRASES_PATH, {})


func categories() -> Array:
	return _categories


func category(id: String) -> Dictionary:
	for c in _categories:
		if c.id == id:
			return c
	return {}


func items(category_id: String) -> Array:
	var list: Array = _items_by_category.get(category_id, [])
	if not require_assets:
		return list
	return list.filter(_has_assets)


func item(id: String) -> Dictionary:
	return _items_by_id.get(id, {})


func phrases() -> Dictionary:
	return _phrases


func voice_path(key: String) -> String:
	return "res://assets/audio/voice/%s.ogg" % key


func image_path(id: String) -> String:
	return "res://assets/images/items/%s.svg" % id


func _has_assets(it: Dictionary) -> bool:
	if it.has("emoji") and not ResourceLoader.exists(image_path(it.id)):
		return false
	for prefix in ["this_", "where_", "name_"]:
		if not ResourceLoader.exists(voice_path(prefix + it.id)):
			return false
	return true


func _read_json(path: String, fallback: Variant) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("ContentDB: cannot open %s" % path)
		return fallback
	var data = JSON.parse_string(f.get_as_text())
	if data == null:
		push_error("ContentDB: bad JSON in %s" % path)
		return fallback
	return data
