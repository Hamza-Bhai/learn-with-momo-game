extends Control
## Parents area (behind a sum question): daily time limit, 10 more minutes, reset, credits.

var _body: VBoxContainer
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UI.add_background(self)
	_rng.randomize()
	add_child(Screen.back_button())
	_body = VBoxContainer.new()
	_body.set_anchors_preset(Control.PRESET_FULL_RECT)
	_body.offset_left = 150
	_body.offset_right = -150
	_body.offset_top = 40
	_body.offset_bottom = -30
	_body.alignment = BoxContainer.ALIGNMENT_CENTER
	_body.add_theme_constant_override("separation", 22)
	add_child(_body)
	_show_gate()


func _clear() -> void:
	for c in _body.get_children():
		c.queue_free()


func _show_gate() -> void:
	_clear()
	var q := ParentGate.make(_rng)
	_body.add_child(UI.label("Parents only", 40))
	_body.add_child(UI.label(q.text, 72))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	_body.add_child(row)
	for c in q.choices:
		var b := _text_button(str(c), 48, Vector2(140, 120))
		b.pressed.connect(func():
			if ParentGate.check(q, c):
				_show_settings()
			else:
				_show_gate())
		row.add_child(b)


func _show_settings() -> void:
	_clear()
	_body.add_child(UI.label("Daily play time", 40))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	_body.add_child(row)
	var current := int(Progress.store.settings().limit_minutes)
	for m in ProgressStore.LIMITS:
		var text := "Off" if m == 0 else "%d min" % m
		var b := _text_button(text, 32, Vector2(150, 90), m == current)
		b.pressed.connect(func():
			TimerService.set_limit(m)
			_show_settings())
		row.add_child(b)

	var used := int(TimerService.timer.state().used_sec / 60.0)
	_body.add_child(UI.label("Played today: %d min" % used, 28))

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 24)
	_body.add_child(actions)
	var more := _text_button("+10 min today", 30, Vector2(280, 90))
	more.pressed.connect(func():
		TimerService.add_bonus_minutes(10)
		_show_settings())
	actions.add_child(more)
	var reset := _text_button("Reset stickers", 30, Vector2(280, 90))
	reset.pressed.connect(_confirm_reset)
	actions.add_child(reset)
	var done := _text_button("Done", 30, Vector2(200, 90), true)
	done.pressed.connect(_leave)
	actions.add_child(done)

	var credits := Label.new()
	credits.text = _credits_text()
	credits.add_theme_font_size_override("font_size", 16)
	credits.add_theme_color_override("font_color", UI.INK)
	credits.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.add_child(credits)


func _confirm_reset() -> void:
	_clear()
	_body.add_child(UI.label("Delete all stickers and outfits?", 40))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	_body.add_child(row)
	var yes := _text_button("Yes, reset", 32, Vector2(260, 100))
	yes.pressed.connect(func():
		Progress.store.reset_progress()
		Progress.store.save()
		_show_settings())
	row.add_child(yes)
	var no := _text_button("No", 32, Vector2(200, 100), true)
	no.pressed.connect(_show_settings)
	row.add_child(no)


func _leave() -> void:
	if TimerService.is_time_up():
		Nav.go_root(Nav.TIME_UP)
	else:
		Nav.go_root(Nav.HOME)


func _text_button(text: String, font_size: int, min_size: Vector2, selected := false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", UI.INK)
	b.add_theme_color_override("font_pressed_color", UI.INK)
	b.add_theme_color_override("font_hover_color", UI.INK)
	var bg := Color("#FFD54F") if selected else UI.CARD
	for state in ["normal", "hover", "focus"]:
		b.add_theme_stylebox_override(state, UI.style(bg, 24))
	b.add_theme_stylebox_override("pressed", UI.style(bg.darkened(0.1), 24))
	return b


func _credits_text() -> String:
	return "Pictures: Twemoji (CC-BY 4.0) by Twitter, Inc. and contributors. " \
		+ "Voice: Piper TTS. Made with Godot Engine."
