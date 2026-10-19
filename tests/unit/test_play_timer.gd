extends GutTest

const DAY := "2026-10-19"


func _timer(limit: int, used := 0.0) -> PlayTimer:
	return PlayTimer.new({"date": DAY, "used_sec": used, "bonus_sec": 0.0}, limit)


func _run(t: PlayTimer, seconds: int, today := DAY):
	for i in seconds:
		t.tick(1.0, today)


func test_limit_off_never_up():
	var t := _timer(0)
	_run(t, 4000)
	assert_false(t.is_time_up())


func test_up_after_limit():
	var t := _timer(10)
	_run(t, 599)
	assert_false(t.is_time_up())
	_run(t, 1)
	assert_true(t.is_time_up())


func test_paused_does_not_accumulate():
	var t := _timer(10)
	t.set_paused(true)
	_run(t, 1000)
	assert_eq(t.state().used_sec, 0.0)
	t.set_paused(false)
	_run(t, 5)
	assert_eq(t.state().used_sec, 5.0)


func test_new_date_resets():
	var t := _timer(10, 600.0)
	assert_true(t.is_time_up())
	t.tick(1.0, "2026-10-20")
	assert_false(t.is_time_up())
	assert_eq(t.state().date, "2026-10-20")
	assert_eq(t.state().used_sec, 1.0)


func test_clock_backwards_no_negative():
	var t := _timer(10, 300.0)
	t.tick(1.0, "2026-10-18")
	assert_gte(t.state().used_sec, 0.0)
	assert_lt(t.state().used_sec, 2.0)
	t.tick(-50.0, "2026-10-18")
	assert_gte(t.state().used_sec, 0.0)


func test_huge_delta_ignored():
	var t := _timer(10)
	t.tick(3600.0, DAY)
	assert_eq(t.state().used_sec, 0.0)


func test_bonus_extends():
	var t := _timer(10, 600.0)
	assert_true(t.is_time_up())
	t.add_bonus_minutes(10)
	assert_false(t.is_time_up())
	_run(t, 600)
	assert_true(t.is_time_up())


func test_bonus_after_time_up_gives_full_ten_minutes():
	var t := _timer(10)
	_run(t, 900)  # 5 extra minutes sitting on the time-up screen
	t.add_bonus_minutes(10)
	_run(t, 599)
	assert_false(t.is_time_up())


func test_set_limit_changes_threshold():
	var t := _timer(10, 700.0)
	t.set_limit(15)
	assert_false(t.is_time_up())
	t.set_limit(0)
	assert_false(t.is_time_up())


func test_empty_state_is_valid():
	var t := PlayTimer.new({}, 10)
	t.tick(1.0, DAY)
	assert_eq(t.state().date, DAY)
	assert_eq(t.state().used_sec, 1.0)
