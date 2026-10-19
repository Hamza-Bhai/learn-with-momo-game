class_name Momo
extends Control
## Momo the monkey: bobs while talking, dances on a win, scratches his head on a miss,
## and wears the outfit the child unlocked. Tap him to hear the question again.

signal tapped

## Outfit placement relative to Momo's face: [offset as fraction of size, scale].
const OUTFIT_POS := {
	"crown": [Vector2(0, -0.42), 0.6], "top_hat": [Vector2(0, -0.48), 0.62], "cap": [Vector2(0, -0.40), 0.62],
	"sunglasses": [Vector2(0, -0.05), 0.62], "bow": [Vector2(0.28, -0.36), 0.42],
	"grad_cap": [Vector2(0, -0.44), 0.62], "flower": [Vector2(0.30, -0.30), 0.38], "helmet": [Vector2(0, -0.40), 0.66],
}

var _body := Control.new()
var _face: TextureRect
var _outfit: TextureRect
var _px: int
var _anim: Tween


static func create(px := 200) -> Momo:
	var m := Momo.new()
	m._px = px
	return m


func _ready() -> void:
	custom_minimum_size = Vector2(_px, _px)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_body.size = size
	_body.pivot_offset = size / 2
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_body)
	_face = UI.texture_rect(UI.ui_icon("momo"), _px)
	_face.size = size
	_body.add_child(_face)
	_outfit = UI.texture_rect(null, _px)
	_outfit.visible = false
	_body.add_child(_outfit)
	wear(Progress.store.worn_outfit())
	idle()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit()
		accept_event()


func wear(outfit_id: String) -> void:
	if outfit_id == "" or not OUTFIT_POS.has(outfit_id):
		_outfit.visible = false
		return
	var pos: Array = OUTFIT_POS[outfit_id]
	var s: float = pos[1] * _px
	_outfit.texture = UI.ui_icon("outfit_" + outfit_id)
	_outfit.custom_minimum_size = Vector2(s, s)
	_outfit.size = Vector2(s, s)
	_outfit.position = size / 2 + (pos[0] as Vector2) * _px - Vector2(s, s) / 2
	_outfit.visible = true


func idle() -> void:
	_restart()
	_anim.set_loops()
	_anim.tween_property(_body, "position:y", -6.0, 1.1).set_trans(Tween.TRANS_SINE)
	_anim.tween_property(_body, "position:y", 0.0, 1.1).set_trans(Tween.TRANS_SINE)


func talk() -> void:
	_restart()
	_anim.set_loops(6)
	_anim.tween_property(_body, "scale", Vector2(1.05, 0.95), 0.12)
	_anim.tween_property(_body, "scale", Vector2.ONE, 0.12)
	_anim.finished.connect(idle)


func dance() -> void:
	_restart()
	_anim.set_loops(3)
	_anim.tween_property(_body, "rotation", 0.25, 0.12)
	_anim.parallel().tween_property(_body, "position:y", -30.0, 0.12)
	_anim.tween_property(_body, "rotation", -0.25, 0.16)
	_anim.parallel().tween_property(_body, "position:y", 0.0, 0.16)
	_anim.tween_property(_body, "rotation", 0.0, 0.1)
	_anim.finished.connect(idle)


func scratch_head() -> void:
	_restart()
	_anim.tween_property(_body, "rotation", -0.18, 0.15)
	_anim.tween_property(_body, "rotation", -0.1, 0.12)
	_anim.tween_property(_body, "rotation", -0.18, 0.12)
	_anim.tween_property(_body, "rotation", 0.0, 0.2)
	_anim.finished.connect(idle)


func wave() -> void:
	_restart()
	_anim.set_loops()
	_anim.tween_property(_body, "rotation", 0.12, 0.5).set_trans(Tween.TRANS_SINE)
	_anim.tween_property(_body, "rotation", -0.12, 0.5).set_trans(Tween.TRANS_SINE)


func _restart() -> void:
	if _anim:
		_anim.kill()
	_body.rotation = 0.0
	_body.scale = Vector2.ONE
	_body.position = Vector2.ZERO
	_anim = create_tween()

