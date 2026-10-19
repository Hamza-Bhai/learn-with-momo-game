class_name ProgressStore
extends RefCounted
## Stickers, outfits, settings and timer state, saved as one JSON file.
## A missing or broken file always falls back to defaults.

const LIMITS := [0, 10, 15, 20, 30]

var _path: String
var _data: Dictionary


func _init(path: String) -> void:
	_path = path
	_data = _defaults()


static func _defaults() -> Dictionary:
	return {
		"stickers": {},  # item_id -> true
		"rounds_won": {},  # category_id -> int
		"outfits": [],
		"worn_outfit": "",
		"last_round_token": -1,
		"settings": {"limit_minutes": 0},
		"timer": {"date": "", "used_sec": 0.0, "bonus_sec": 0.0},
	}


func load_or_default() -> void:
	_data = _defaults()
	if not FileAccess.file_exists(_path):
		return
	var f := FileAccess.open(_path, FileAccess.READ)
	if f == null:
		return
	var json := JSON.new()
	var parsed = json.data if json.parse(f.get_as_text()) == OK else null
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("ProgressStore: unreadable save, using defaults")
		return
	for key in _data.keys():
		if parsed.has(key) and typeof(parsed[key]) == typeof(_data[key]):
			_data[key] = parsed[key]
	# JSON stores every number as float; the limit is compared as an int.
	_data.settings.limit_minutes = int(_data.settings.get("limit_minutes", 0))
	if not LIMITS.has(_data.settings.limit_minutes):
		_data.settings.limit_minutes = 0


func save() -> void:
	var tmp := _path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_error("ProgressStore: cannot write %s" % tmp)
		return
	f.store_string(JSON.stringify(_data))
	f.close()
	DirAccess.rename_absolute(tmp, _path)


func award_sticker(category_id: String, item_ids: Array, round_token: int, outfit_id := "") -> Dictionary:
	var result := {"sticker": "", "outfit": ""}
	if int(_data.last_round_token) == round_token:
		return result
	_data.last_round_token = round_token
	_data.rounds_won[category_id] = rounds_won(category_id) + 1
	for id in item_ids:
		if not has_sticker(id):
			_data.stickers[id] = true
			result.sticker = id
			break
	if result.sticker != "" and page_complete(category_id, item_ids) and outfit_id != "" \
			and not _data.outfits.has(outfit_id):
		_data.outfits.append(outfit_id)
		result.outfit = outfit_id
	return result


func has_sticker(item_id: String) -> bool:
	return _data.stickers.has(item_id)


func page_complete(_category_id: String, item_ids: Array) -> bool:
	return item_ids.all(func(id): return has_sticker(id))


func rounds_won(category_id: String) -> int:
	return int(_data.rounds_won.get(category_id, 0))


func outfits() -> Array:
	return _data.outfits


func worn_outfit() -> String:
	return _data.worn_outfit


func set_worn_outfit(id: String) -> void:
	if id == "" or _data.outfits.has(id):
		_data.worn_outfit = id


func settings() -> Dictionary:
	return _data.settings


func set_limit_minutes(m: int) -> void:
	if LIMITS.has(m):
		_data.settings.limit_minutes = m


func reset_progress() -> void:
	var keep_settings: Dictionary = _data.settings
	var keep_timer: Dictionary = _data.timer
	_data = _defaults()
	_data.settings = keep_settings
	_data.timer = keep_timer


func timer_state() -> Dictionary:
	return _data.timer


func set_timer_state(d: Dictionary) -> void:
	_data.timer = d.duplicate()
