extends Node
## Autoload "Nav": scene changes with a short fade and a back history.
## Calls made while a fade is running are ignored, so double taps open a screen once.
## Back button / Escape goes one screen back unless the current scene sets blocks_back.

const FADE := 0.12

const HOME := "res://scenes/home/home.tscn"
const CATEGORY := "res://scenes/category/category.tscn"
const LEARN := "res://scenes/learn/learn.tscn"
const PLAY := "res://scenes/play/play.tscn"
const REWARD := "res://scenes/reward/reward.tscn"
const ALBUM := "res://scenes/album/album.tscn"
const PARENTS := "res://scenes/parents/parents.tscn"
const TIME_UP := "res://scenes/time_up/time_up.tscn"

var greeted := false

var _params := {}
var _history: Array = []  # [{path, params}]
var _current := {"path": HOME, "params": {}}
var _busy := false
var _fade := ColorRect.new()
var _tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade.color = Color(1, 1, 1, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)
	_start_from_cmdline.call_deferred()


## Debug/screenshot hook: godot ... -- --start=res://scenes/x.tscn --cat=colors
func _start_from_cmdline() -> void:
	var p := {}
	var start := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--start="):
			start = arg.trim_prefix("--start=")
		elif arg.begins_with("--cat="):
			p["category"] = arg.trim_prefix("--cat=")
	if start != "":
		greeted = true
		go_root(start, p)


## Opens a screen. replace=true swaps the current screen out of the history
## (used so back from Reward returns to Category, not to a finished Play round).
func go(path: String, params := {}, replace := false) -> void:
	if _busy:
		return
	if not replace:
		_history.append(_current)
	_switch(path, params)


## Opens a screen with an empty history (Home, Time-up).
func go_root(path: String, params := {}) -> void:
	_history.clear()
	_busy = false
	_switch(path, params)


func back() -> void:
	if _busy or _history.is_empty():
		return
	var prev: Dictionary = _history.pop_back()
	_switch(prev.path, prev.params)


func params() -> Dictionary:
	return _params


func _switch(path: String, p: Dictionary) -> void:
	_busy = true
	_current = {"path": path, "params": p}
	Voice.stop()
	if _tween:
		_tween.kill()  # a newer switch (e.g. time-up) wins over one still fading
	var t := create_tween()
	_tween = t
	t.tween_property(_fade, "color:a", 1.0, FADE)
	t.tween_callback(func():
		_params = p
		get_tree().change_scene_to_file(path))
	t.tween_property(_fade, "color:a", 0.0, FADE)
	t.tween_callback(func(): _busy = false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back_request()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_request()


func _on_back_request() -> void:
	var scene := get_tree().current_scene
	if scene and scene.get("blocks_back") == true:
		return
	back()
