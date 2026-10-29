extends Control
## Play: "Where is the turtle?" with 2-3 pictures. Right = party, wrong = try again.

const CELEBRATE_SEC := 1.2
const PRAISE := ["great_job", "well_done", "yay"]

var _category: Dictionary
var _items: Array
var _session: RoundSession
var _round_token: int
var _row: HBoxContainer
var _dots: HBoxContainer
var _momo: Momo
var _buttons := {}  # item_id -> BigButton


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UI.add_background(self)
	_category = ContentDB.category(Nav.params().get("category", "colors"))
	_items = ContentDB.items(_category.id)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_session = RoundSession.new(_items, Progress.store.rounds_won(_category.id), rng)
	_round_token = Time.get_ticks_usec()

	_dots = HBoxContainer.new()
	_dots.alignment = BoxContainer.ALIGNMENT_CENTER
	_dots.add_theme_constant_override("separation", 14)
	_dots.anchor_right = 1.0
	_dots.offset_top = 40
	add_child(_dots)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 50)
	center.add_child(_row)

	add_child(Screen.back_button())
	_momo = Screen.corner_momo(self)
	_momo.tapped.connect(_ask)
	_show_question()


func _show_question() -> void:
	for c in _row.get_children():
		c.queue_free()
	_buttons.clear()
	_refresh_dots()
	var q := _session.current()
	var px := 300 if q.options.size() == 2 else 250
	var i := 0
	for id in q.options:
		var b := BigButton.create(UI.item_visual(ContentDB.item(id), px), "", UI.CARD, px + 60)
		b.tapped.connect(_on_tap.bind(id))
		_row.add_child(b)
		_buttons[id] = b
		UI.pop_in(b, i * 0.08)
		i += 1
	_ask()


func _ask() -> void:
	if _session.is_finished():
		return
	Voice.play("where_" + _session.current().target)
	_momo.talk()


func _on_tap(id: String) -> void:
	match _session.answer(id):
		"correct":
			_celebrate(_buttons[id])
		"wrong":
			UI.wiggle(_buttons[id])
			Voice.play_sfx("boop")
			Voice.play("try_again")
			_momo.scratch_head()


func _celebrate(b: BigButton) -> void:
	UI.bounce(b, 1.25)
	Voice.play_sfx("clap")
	Voice.play_sfx("confetti")
	Voice.play(PRAISE[randi() % PRAISE.size()])
	_momo.dance()
	Confetti.burst(self, b.get_global_rect().get_center())
	await get_tree().create_timer(CELEBRATE_SEC).timeout
	if not is_inside_tree():
		return
	_session.unlock()
	if _session.is_finished():
		Nav.go(Nav.REWARD, {"category": _category.id, "round_token": _round_token}, true)
	else:
		_show_question()


func _refresh_dots() -> void:
	for c in _dots.get_children():
		c.queue_free()
	for i in 5:
		var d := Panel.new()
		d.custom_minimum_size = Vector2(34, 34)
		var done := i < _session.index()
		d.add_theme_stylebox_override("panel", UI.style(Color("#FFC107") if done else Color(1, 1, 1, 0.7), 17, false))
		_dots.add_child(d)
