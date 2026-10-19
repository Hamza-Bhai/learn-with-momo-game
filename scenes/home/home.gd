extends Control
## Home: one big card per category, the sticker album, and a small parents button.

var blocks_back := true  # nothing behind Home; the back button must not exit the game

var _momo: Momo


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UI.add_background(self)

	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		root.add_theme_constant_override("margin_" + side, 28)
	add_child(root)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	root.add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 20)
	col.add_child(top)
	_momo = Momo.create(110)
	_momo.tapped.connect(func(): Voice.play("hello"); _momo.talk())
	top.add_child(_momo)
	var title := UI.label("Learn with Momo", 56)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var album := BigButton.create(UI.texture_rect(UI.ui_icon("album"), 76), "album", Color("#FFE082"), 110)
	album.tapped.connect(func(): Nav.go(Nav.ALBUM))
	top.add_child(album)
	var parent_btn := BigButton.create(UI.texture_rect(UI.ui_icon("parent"), 40), "", Color(1, 1, 1, 0.6), 64)
	parent_btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	parent_btn.tapped.connect(func(): Nav.go(Nav.PARENTS))
	top.add_child(parent_btn)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 22)
	col.add_child(grid)

	var i := 0
	for c in ContentDB.categories():
		grid.add_child(_category_card(c, UI.ACCENTS[i % UI.ACCENTS.size()]))
		i += 1

	if not Nav.greeted:
		Nav.greeted = true
		Voice.play("hello")
		_momo.talk()


func _category_card(c: Dictionary, accent: Color) -> Control:
	var locked := _is_locked(c)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_holder := Control.new()
	icon_holder.custom_minimum_size = Vector2(130, 130)
	icon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon := UI.item_visual(ContentDB.item(c.icon_item), 130, false)
	icon_holder.add_child(icon)
	if locked:
		icon.modulate = Color(1, 1, 1, 0.35)
		var lock := UI.texture_rect(UI.ui_icon("lock"), 64)
		lock.position = Vector2(66, 66)
		icon_holder.add_child(lock)
	box.add_child(icon_holder)
	box.add_child(UI.label(c.name, 26))
	var card := BigButton.create(box, "cat_" + c.id, accent.lightened(0.55), 150)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.tapped.connect(func():
		if locked:
			Voice.play_sfx("boop")
			UI.wiggle(card)
		else:
			Nav.go(Nav.CATEGORY, {"category": c.id}))
	return card


func _is_locked(c: Dictionary) -> bool:
	var after = c.get("unlock_after")
	if after == null or after == "":
		return false
	var ids := ContentDB.items(after).map(func(it): return it.id)
	return not Progress.store.page_complete(after, ids)
