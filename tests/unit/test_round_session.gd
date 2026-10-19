extends GutTest

const COLORS := [
	{"id": "red", "avoid_with": ["pink", "orange"]},
	{"id": "blue", "avoid_with": []},
	{"id": "yellow", "avoid_with": ["orange"]},
	{"id": "green", "avoid_with": []},
	{"id": "orange", "avoid_with": ["red", "yellow"]},
	{"id": "pink", "avoid_with": ["red"]},
]
const THREE := [{"id": "a"}, {"id": "b"}, {"id": "c"}]


func _rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r


func _play_through(s: RoundSession) -> Array:
	var targets := []
	while not s.is_finished():
		var q := s.current()
		targets.append(q.target)
		assert_eq(s.answer(q.target), "correct")
		s.unlock()
	return targets


func test_options_count_2_then_3():
	assert_eq(RoundSession.options_count(0), 2)
	assert_eq(RoundSession.options_count(2), 2)
	assert_eq(RoundSession.options_count(3), 3)
	assert_eq(RoundSession.options_count(10), 3)


func test_five_questions():
	var s := RoundSession.new(COLORS, 0, _rng(1))
	assert_eq(_play_through(s).size(), 5)


func test_target_in_options():
	for seed_value in 30:
		var s := RoundSession.new(COLORS, 5, _rng(seed_value))
		while not s.is_finished():
			var q := s.current()
			assert_has(q.options, q.target)
			assert_eq(q.options.size(), 3)
			s.answer(q.target)
			s.unlock()


func test_options_unique():
	for seed_value in 30:
		var s := RoundSession.new(COLORS, 5, _rng(seed_value))
		while not s.is_finished():
			var q := s.current()
			var seen := {}
			for o in q.options:
				assert_false(seen.has(o), "duplicate option %s" % o)
				seen[o] = true
			s.answer(q.target)
			s.unlock()


func test_avoid_with_respected():
	for seed_value in 50:
		var s := RoundSession.new(COLORS, 5, _rng(seed_value))
		while not s.is_finished():
			var q := s.current()
			if q.target == "red":
				assert_does_not_have(q.options, "pink")
				assert_does_not_have(q.options, "orange")
			if q.target == "pink":
				assert_does_not_have(q.options, "red")
			s.answer(q.target)
			s.unlock()


func test_five_distinct_targets_when_enough_items():
	for seed_value in 20:
		var targets := _play_through(RoundSession.new(COLORS, 0, _rng(seed_value)))
		var uniq := {}
		for t in targets:
			uniq[t] = true
		assert_eq(uniq.size(), 5)


func test_no_same_target_twice_in_a_row():
	for seed_value in 50:
		var targets := _play_through(RoundSession.new(THREE, 0, _rng(seed_value)))
		for i in range(1, targets.size()):
			assert_ne(targets[i], targets[i - 1])


func test_wrong_keeps_same_question():
	var s := RoundSession.new(COLORS, 0, _rng(3))
	var q := s.current()
	var wrong: String = q.options[0] if q.options[0] != q.target else q.options[1]
	assert_eq(s.answer(wrong), "wrong")
	assert_eq(s.index(), 0)
	assert_eq(s.current().target, q.target)


func test_answer_ignored_while_locked():
	var s := RoundSession.new(COLORS, 0, _rng(4))
	var q := s.current()
	assert_eq(s.answer(q.target), "correct")
	assert_eq(s.answer(q.target), "ignored")
	assert_eq(s.answer("blue"), "ignored")
	assert_eq(s.index(), 0)
	s.unlock()
	assert_eq(s.index(), 1)


func test_unknown_option_is_ignored():
	var s := RoundSession.new(COLORS, 0, _rng(5))
	assert_eq(s.answer("not_an_option"), "ignored")


func test_finished_after_five_correct_and_unlocks():
	var s := RoundSession.new(COLORS, 0, _rng(6))
	for i in 5:
		assert_false(s.is_finished())
		s.answer(s.current().target)
		s.unlock()
	assert_true(s.is_finished())
	assert_eq(s.answer("red"), "ignored")
