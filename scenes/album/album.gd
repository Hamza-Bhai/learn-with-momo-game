extends Control
## Sticker album: one page per category. Missing stickers show as a faint shadow.
## A full page shows its outfit; tapping it makes Momo wear it.

var _page := 0
var _cats: Array
var _content: VBoxContainer
var _momo: Momo


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UI.add_background(self)
	_cats = ContentDB.categories()

	_content = VBoxContainer.new()
	_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content.offset_left = 180
	_content.offset_right = -180
	_content.offset_top = 30
	_content.offset_bottom = -30
	_content.add_theme_constant_override("separation", 16)
	add_child(_content)

	for dir in [-1, 1]:
		var b := BigButton.create(UI.texture_rect(UI.ui_icon("arrow_left" if dir < 0 else "arrow_right"), 70), "",
				Color(1, 1, 1, 0.8), 120)
		b.anchor_top = 0.5
		b.anchor_bottom = 0.5
		b.offset_top = -60
		if dir > 0:
			b.anchor_left = 1.0
			b.anchor_right = 1.0
			b.offset_left = -150
		else:
			b.offset_left = 30
			b.offset_top = 20
		b.tapped.connect(func(): _show(_page + dir))
		add_child(b)

	add_child(Screen.back_button())
	_momo = Screen.corner_momo(self, 130)
	_show(0)


func _show(p: int) -> void:
	_page = posmod(p, _cats.size())
	for c in _content.get_children():
		c.queue_free()
	var cat: Dictionary = _cats[_page]
	var items := ContentDB.items(cat.id)
	var ids := items.map(func(it): return it.id)

	var header := BigButton.create(UI.label(cat.name, 48), "cat_" + cat.id, Color(1, 1, 1, 0.6), 80)
	header.custom_minimum_size = Vector2(0, 80)
	_content.add_child(header)
	Voice.play("cat_" + cat.id)

	var grid := GridContainer.new()
	grid.columns = 5
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	_content.add_child(grid)
	var px := 120 if items.size() <= 10 else 90
	for it in items:
		var owned := Progress.store.has_sticker(it.id)
		var vis := UI.item_visual(it, px - 20, false)
		if not owned:
			vis.modulate = Color(0, 0, 0, 0.15)
		var b := BigButton.create(vis, "name_" + it.id if owned else "", UI.CARD if owned else Color(1, 1, 1, 0.5), px)
		grid.add_child(b)

	if Progress.store.page_complete(cat.id, ids):
		var outfit_btn := BigButton.create(UI.texture_rect(UI.ui_icon("outfit_" + cat.outfit), 80), "",
				Color("#FFF59D"), 110)
		outfit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		outfit_btn.tapped.connect(func():
			Progress.store.set_worn_outfit(cat.outfit)
			Progress.store.save()
			_momo.wear(cat.outfit)
			_momo.dance())
		_content.add_child(outfit_btn)
