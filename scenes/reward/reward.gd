extends Control
## Reward: the new sticker flies into the album. A full page gives Momo a new outfit.

var _can_leave := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UI.add_background(self)
	var p := Nav.params()
	var category := ContentDB.category(p.get("category", "colors"))
	var ids := ContentDB.items(category.id).map(func(it): return it.id)
	var result := Progress.store.award_sticker(category.id, ids, int(p.get("round_token", 0)), category.outfit)
	Progress.store.save()

	var album := UI.texture_rect(UI.ui_icon("album"), 110)
	album.anchor_left = 1.0
	album.anchor_right = 1.0
	album.offset_left = -150
	album.offset_top = 30
	add_child(album)

	var momo := Momo.create(220)
	momo.anchor_left = 0.5
	momo.anchor_top = 1.0
	momo.offset_left = -110
	momo.offset_top = -250
	add_child(momo)

	if result.sticker != "":
		await _fly_sticker(ContentDB.item(result.sticker), album)
		if not is_inside_tree():
			return
		_stars()
		Voice.play("got_sticker")
		momo.dance()
	else:
		_stars()
		Voice.play("great_job")
		momo.dance()
	if result.outfit != "":
		await get_tree().create_timer(1.6).timeout
		if not is_inside_tree():
			return
		Progress.store.set_worn_outfit(result.outfit)
		Progress.store.save()
		momo.wear(result.outfit)
		UI.bounce(momo, 1.3)
		Confetti.burst(self, momo.get_global_rect().get_center())
		Voice.play("new_outfit")
		momo.dance()
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree():
		_can_leave = true


func _gui_input(event: InputEvent) -> void:
	if _can_leave and event is InputEventMouseButton and event.pressed:
		_can_leave = false
		Nav.back()


func _fly_sticker(item: Dictionary, album: Control) -> void:
	var s := UI.item_visual(item, 300)
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.size = Vector2(300, 300)
	holder.add_child(s)
	holder.position = (size - holder.size) / 2 - Vector2(0, 60)
	holder.pivot_offset = holder.size / 2
	add_child(holder)
	holder.scale = Vector2.ZERO
	Voice.play_sfx("pop")
	var t := create_tween()
	t.tween_property(holder, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.9)
	t.tween_callback(func(): Voice.play_sfx("whoosh"))
	t.tween_property(holder, "position", album.position + album.size / 2 - holder.size / 2, 0.6).set_trans(Tween.TRANS_QUAD)
	t.parallel().tween_property(holder, "scale", Vector2(0.25, 0.25), 0.6)
	t.tween_callback(func(): UI.bounce(album, 1.3); holder.queue_free())
	await t.finished


func _stars() -> void:
	for i in 5:
		var st := UI.texture_rect(UI.ui_icon("star"), 110)
		st.position = Vector2(size.x / 2 - 330 + i * 140, size.y / 2 - 180)
		add_child(st)
		UI.pop_in(st, i * 0.1)
