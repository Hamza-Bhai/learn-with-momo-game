extends Node
## Autoload "TimerService": runs the PlayTimer while the app is in front,
## saves it through Progress, and emits time_up once when the limit is reached.

signal time_up

const SAVE_EVERY := 10.0

var timer: PlayTimer
var _since_save := 0.0
var _was_up := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer = PlayTimer.new(Progress.store.timer_state(), int(Progress.store.settings().limit_minutes))
	timer.tick(0.0, _today())
	_was_up = timer.is_time_up()


func _process(delta: float) -> void:
	timer.tick(delta, _today())
	_since_save += delta
	if _since_save >= SAVE_EVERY:
		_save()
	var up := timer.is_time_up()
	if up and not _was_up:
		_save()
		time_up.emit()
	_was_up = up


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			timer.set_paused(true)
			Voice.stop()
			_save()
		NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN:
			timer.set_paused(false)
		NOTIFICATION_WM_CLOSE_REQUEST:
			_save()


func is_time_up() -> bool:
	return timer.is_time_up()


func set_limit(m: int) -> void:
	Progress.store.set_limit_minutes(m)
	timer.set_limit(int(Progress.store.settings().limit_minutes))
	_was_up = timer.is_time_up()
	_save()


func add_bonus_minutes(m: int) -> void:
	timer.add_bonus_minutes(m)
	_was_up = timer.is_time_up()
	_save()


func _save() -> void:
	_since_save = 0.0
	Progress.store.set_timer_state(timer.state())
	Progress.store.save()


func _today() -> String:
	return Time.get_date_string_from_system()
