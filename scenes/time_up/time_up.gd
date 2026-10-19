extends Control
## Time is up for today. Only a parent (through the sum question) can open the game again.

var blocks_back := true


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("#C5CAE9")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 20)
	add_child(col)
	var holder := CenterContainer.new()
	col.add_child(holder)
	var momo := Momo.create(280)
	holder.add_child(momo)
	col.add_child(UI.label("Bye bye! See you tomorrow!", 56))
	momo.wave()
	Voice.play("bye")

	var parent_btn := BigButton.create(UI.texture_rect(UI.ui_icon("parent"), 40), "", Color(1, 1, 1, 0.6), 64)
	parent_btn.anchor_left = 1.0
	parent_btn.anchor_right = 1.0
	parent_btn.offset_left = -96
	parent_btn.offset_right = -32
	parent_btn.offset_top = 24
	parent_btn.tapped.connect(func(): Nav.go(Nav.PARENTS))
	add_child(parent_btn)
