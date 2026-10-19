extends GutTest


func _rng(s: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = s
	return r


func test_answer_is_sum():
	for s in 50:
		var q := ParentGate.make(_rng(s))
		var parts: PackedStringArray = q.text.replace(" = ?", "").split(" + ")
		assert_eq(int(parts[0]) + int(parts[1]), q.answer)
		assert_between(int(parts[0]), 3, 9)
		assert_between(int(parts[1]), 3, 9)


func test_four_unique_choices_contain_answer():
	for s in 100:
		var q := ParentGate.make(_rng(s))
		assert_eq(q.choices.size(), 4)
		assert_has(q.choices, q.answer)
		var seen := {}
		for c in q.choices:
			assert_false(seen.has(c))
			seen[c] = true
			assert_between(c, 6, 18)


func test_check():
	var q := ParentGate.make(_rng(1))
	assert_true(ParentGate.check(q, q.answer))
	assert_false(ParentGate.check(q, q.answer + 1))
