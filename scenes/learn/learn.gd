extends Control
## Learn: one picture at a time with its English name. Never moves on by itself.

var _items: Array
var _index := 0
var _card: BigButton
var _momo: Momo
var _holder: CenterContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UI.add_background(self)
	_items = ContentDB.items(Nav.params().get("category", "colors"))

	_holder = CenterContainer.new()
	_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_holder)

	var left := BigButton.create(UI.texture_rect(UI.ui_icon("arrow_left"), 90), "", Color(1, 1, 1, 0.8), 140)
	left.anchor_top = 0.5
	left.anchor_bottom = 0.5
	left.offset_left = 60
	left.offset_top = -70
	left.tapped.connect(func(): _show(_index - 1))
	add_child(left)
	var right := BigButton.create(UI.texture_rect(UI.ui_icon("arrow_right"), 90), "", Color(1, 1, 1, 0.8), 140)
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.anchor_top = 0.5
	right.anchor_bottom = 0.5
	right.offset_left = -200
	right.offset_right = -60
	right.offset_top = -70
	right.tapped.connect(func(): _show(_index + 1))
	add_child(right)

	add_child(Screen.back_button())
	_momo = Screen.corner_momo(self)
	_momo.tapped.connect(_say)
	_show(0)


func _show(i: int) -> void:
	if _items.is_empty():
		return
	_index = posmod(i, _items.size())
	if _card:
		_card.queue_free()
	var item: Dictionary = _items[_index]
	_card = BigButton.create(UI.item_visual(item, 360), "", UI.CARD, 460)
	_card.tapped.connect(_say)
	_holder.add_child(_card)
	UI.pop_in(_card)
	_say()


func _say() -> void:
	Voice.play("this_" + _items[_index].id)
	_momo.talk()
