class_name BigButton
extends Button
## A big rounded card button for small fingers. Says its voice line, bounces,
## then emits tapped right away (it does not wait for the voice to finish).

signal tapped

var voice_key := ""
var content: Control


static func create(content_node: Control, voice: String, bg := UI.CARD, min_px := 200) -> BigButton:
	var b := BigButton.new()
	b.voice_key = voice
	b.custom_minimum_size = Vector2(min_px, min_px)
	b.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "focus", "disabled"]:
		b.add_theme_stylebox_override(state, UI.style(bg))
	b.add_theme_stylebox_override("pressed", UI.style(bg.darkened(0.08)))
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(content_node)
	b.add_child(center)
	b.content = content_node
	return b


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if voice_key != "":
		Voice.play(voice_key)
	Voice.play_sfx("pop")
	UI.bounce(self, 1.06)
	tapped.emit()
