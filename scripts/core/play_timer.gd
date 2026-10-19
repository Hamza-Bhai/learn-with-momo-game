class_name PlayTimer
extends RefCounted
## Today's play time against the parent's limit. Time is injected so it can be tested.
## Counts nothing while paused or once time is up, ignores impossible frame deltas,
## and starts over whenever the calendar date changes (either direction).

const MAX_DELTA := 5.0

var _state: Dictionary
var _limit_minutes: int
var _paused := false


func _init(state: Dictionary, limit_minutes: int) -> void:
	_state = {
		"date": str(state.get("date", "")),
		"used_sec": maxf(float(state.get("used_sec", 0.0)), 0.0),
		"bonus_sec": maxf(float(state.get("bonus_sec", 0.0)), 0.0),
	}
	_limit_minutes = limit_minutes


func tick(delta_sec: float, today: String) -> void:
	if _paused:
		return
	if today != _state.date:
		_state = {"date": today, "used_sec": 0.0, "bonus_sec": 0.0}
	if delta_sec < 0.0 or delta_sec > MAX_DELTA or is_time_up():
		return
	_state.used_sec += delta_sec


func set_paused(p: bool) -> void:
	_paused = p


func is_time_up() -> bool:
	if _limit_minutes <= 0:
		return false
	return _state.used_sec >= _allowed_sec()


func add_bonus_minutes(m: int) -> void:
	_state.bonus_sec += m * 60.0


func set_limit(m: int) -> void:
	_limit_minutes = m


func state() -> Dictionary:
	return _state.duplicate()


func _allowed_sec() -> float:
	return _limit_minutes * 60.0 + _state.bonus_sec
