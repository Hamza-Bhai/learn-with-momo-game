extends Control
## Category: two big choices, Learn and Play.

var _category: Dictionary


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UI.add_background(self)
	_category = ContentDB.category(Nav.params().get("category", "colors"))

	add_child(Screen.back_button())

	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 30)
	add_child(col)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 20)
	header.add_child(UI.item_visual(ContentDB.item(_category.icon_item), 110, false))
	header.add_child(UI.label(_category.name, 64))
	col.add_child(header)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 60)
	col.add_child(row)
	var learn := BigButton.create(UI.texture_rect(UI.ui_icon("learn"), 170), "learn", Color("#C8E6C9"), 280)
	learn.tapped.connect(func(): Nav.go(Nav.LEARN, {"category": _category.id}))
	row.add_child(learn)
	var play := BigButton.create(UI.texture_rect(UI.ui_icon("play"), 170), "play", Color("#FFCCBC"), 280)
	play.tapped.connect(func(): Nav.go(Nav.PLAY, {"category": _category.id}))
	row.add_child(play)

	var momo := Screen.corner_momo(self)
	momo.tapped.connect(func(): Voice.play("cat_" + _category.id); momo.talk())
	Voice.play("cat_" + _category.id)
	momo.talk()
