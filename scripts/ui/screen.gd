class_name Screen
extends RefCounted
## Pieces several screens share.


## Home-shaped back button in the top-left corner (not an arrow, so it is not confused with next/previous).
static func back_button() -> BigButton:
	var b := BigButton.create(UI.texture_rect(UI.ui_icon("back"), 64), "", Color(1, 1, 1, 0.75), 100)
	b.position = Vector2(24, 24)
	b.tapped.connect(func(): Nav.back())
	return b


## Momo in the bottom-left corner of a full-screen Control.
static func corner_momo(parent: Control, px := 170) -> Momo:
	var m := Momo.create(px)
	m.anchor_top = 1.0
	m.anchor_bottom = 1.0
	m.offset_left = 24
	m.offset_top = -px - 16
	parent.add_child(m)
	return m
