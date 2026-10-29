class_name RoundSession
extends RefCounted
## One Play round: a fixed list of target items, each asked with 2-3 picture options.
## After a correct answer the session locks until unlock(), so toddler double taps
## during the celebration never count twice.

var _items: Array
var _by_id := {}
var _rng: RandomNumberGenerator
var _n_options: int
var _targets: Array = []
var _options: Array = []
var _index := 0
var _locked := false


static func options_count(rounds_won: int) -> int:
	return 2 if rounds_won < 3 else 3


func _init(items: Array, rounds_won: int, rng: RandomNumberGenerator, questions := 5) -> void:
	_items = items
	_rng = rng
	for it in items:
		_by_id[it.id] = it
	_n_options = mini(options_count(rounds_won), items.size())
	_targets = _pick_targets(questions)
	_build_options()


func current() -> Dictionary:
	if is_finished():
		return {}
	return {"target": _targets[_index], "options": _options}


func answer(item_id: String) -> String:
	if _locked or is_finished() or not _options.has(item_id):
		return "ignored"
	if item_id == _targets[_index]:
		_locked = true
		return "correct"
	return "wrong"


func unlock() -> void:
	if not _locked:
		return
	_locked = false
	_index += 1
	if not is_finished():
		_build_options()


func is_finished() -> bool:
	return _index >= _targets.size()


func index() -> int:
	return _index


func _pick_targets(questions: int) -> Array:
	var ids := _items.map(func(it): return it.id)
	if ids.size() >= questions:
		_shuffle(ids)
		return ids.slice(0, questions)
	var out := []
	for i in questions:
		var choices := ids.filter(func(id): return out.is_empty() or id != out[-1])
		out.append(choices[_rng.randi_range(0, choices.size() - 1)])
	return out


func _build_options() -> void:
	var target: String = _targets[_index]
	var others := _items.map(func(it): return it.id).filter(func(id): return id != target)
	var allowed := others.filter(func(id): return not _clashes(target, id))
	_shuffle(allowed)
	var picked := allowed.slice(0, _n_options - 1)
	if picked.size() < _n_options - 1:
		var rest := others.filter(func(id): return not picked.has(id))
		_shuffle(rest)
		picked.append_array(rest.slice(0, _n_options - 1 - picked.size()))
	picked.append(target)
	_shuffle(picked)
	_options = picked


func _clashes(a: String, b: String) -> bool:
	return _by_id[a].get("avoid_with", []).has(b) or _by_id[b].get("avoid_with", []).has(a)


func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
