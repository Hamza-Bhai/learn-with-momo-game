class_name UI
extends RefCounted
## Shared look and small animations for every screen.

const BG_TOP := Color("#BFE9FF")
const BG_BOTTOM := Color("#FFF3C4")
const INK := Color("#3B3355")
const CARD := Color("#FFFFFF")
const ACCENTS := [Color("#FF8A80"), Color("#FFD54F"), Color("#81C784"), Color("#64B5F6"),
	Color("#BA68C8"), Color("#4DB6AC"), Color("#F06292"), Color("#FFB74D")]


static func ui_icon(icon_name: String) -> Texture2D:
	return load("res://assets/images/ui/%s.svg" % icon_name)


static func style(bg: Color, radius := 40, shadow := true, border := Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.anti_aliasing = true
	if shadow:
		s.shadow_color = Color(0, 0, 0, 0.12)
		s.shadow_size = 10
		s.shadow_offset = Vector2(0, 6)
	if border.a > 0:
		s.border_color = border
		s.set_border_width_all(6)
	return s


## Full-screen soft gradient behind a screen.
static func add_background(parent: Control) -> void:
	var g := Gradient.new()
	g.set_color(0, BG_TOP)
	g.set_color(1, BG_BOTTOM)
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	var r := TextureRect.new()
	r.texture = tex
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	parent.move_child(r, 0)


static func label(text: String, size: int, color := INK) -> Label:
	var l := Label.new()
	l.text = text
	var ls := LabelSettings.new()
	ls.font_size = size
	ls.font_color = color
	ls.outline_size = maxi(4, size / 10)
	ls.outline_color = Color.WHITE
	l.label_settings = ls
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func texture_rect(tex: Texture2D, px: int) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(px, px)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## The picture of one learning item: an emoji image, a colour blob, or a number with apples.
static func item_visual(item: Dictionary, px: int, show_apples := true) -> Control:
	if item.has("color"):
		var p := Panel.new()
		var c := Color(item.color)
		var border := Color("#D0D0D0") if c.get_luminance() > 0.9 else Color.TRANSPARENT
		p.add_theme_stylebox_override("panel", style(c, px / 2, true, border))
		p.custom_minimum_size = Vector2(px, px)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return p
	if item.has("number"):
		var n := int(item.number)
		var box := VBoxContainer.new()
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.custom_minimum_size = Vector2(px, px)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var num := label(str(n), int(px * (0.55 if show_apples else 0.8)), ACCENTS[n % ACCENTS.size()].darkened(0.25))
		box.add_child(num)
		if show_apples:
			var grid := GridContainer.new()
			grid.columns = 5
			grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var apple_px := int(px / (6.0 if n <= 10 else 7.5))
			for i in n:
				grid.add_child(texture_rect(ui_icon("apple"), apple_px))
			var center := CenterContainer.new()
			center.mouse_filter = Control.MOUSE_FILTER_IGNORE
			center.add_child(grid)
			box.add_child(center)
		return box
	return texture_rect(load(ContentDB.image_path(item.id)), px)


static func bounce(node: Control, amount := 1.12) -> void:
	node.pivot_offset = node.size / 2
	var t := node.create_tween()
	t.tween_property(node, "scale", Vector2.ONE * amount, 0.08)
	t.tween_property(node, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func wiggle(node: Control) -> void:
	var x := node.position.x
	var t := node.create_tween()
	for dx in [12, -12, 8, -8, 0]:
		t.tween_property(node, "position:x", x + dx, 0.06)


static func pop_in(node: Control, delay := 0.0) -> void:
	node.pivot_offset = node.custom_minimum_size / 2
	node.scale = Vector2.ZERO
	var t := node.create_tween()
	t.tween_interval(delay)
	t.tween_property(node, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
