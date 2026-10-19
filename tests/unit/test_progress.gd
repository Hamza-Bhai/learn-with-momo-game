extends GutTest

const PATH := "user://test_save.json"
const IDS := ["red", "blue", "green"]

var store: ProgressStore


func before_each():
	_cleanup()
	store = ProgressStore.new(PATH)
	store.load_or_default()


func after_each():
	_cleanup()


func _cleanup():
	for p in [PATH, PATH + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


func _write(text: String):
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func test_award_gives_first_unearned_in_order():
	assert_eq(store.award_sticker("colors", IDS, 1).sticker, "red")
	assert_eq(store.award_sticker("colors", IDS, 2).sticker, "blue")
	assert_true(store.has_sticker("red"))
	assert_true(store.has_sticker("blue"))
	assert_false(store.has_sticker("green"))


func test_award_twice_same_round_gives_one():
	assert_eq(store.award_sticker("colors", IDS, 7).sticker, "red")
	var again := store.award_sticker("colors", IDS, 7)
	assert_eq(again.sticker, "")
	assert_eq(again.outfit, "")
	assert_false(store.has_sticker("blue"))
	assert_eq(store.rounds_won("colors"), 1)


func test_page_complete_unlocks_outfit_once():
	store.award_sticker("colors", IDS, 1, "crown")
	store.award_sticker("colors", IDS, 2, "crown")
	var last := store.award_sticker("colors", IDS, 3, "crown")
	assert_eq(last.sticker, "green")
	assert_eq(last.outfit, "crown")
	assert_true(store.page_complete("colors", IDS))
	assert_eq(store.outfits(), ["crown"])
	assert_eq(store.award_sticker("colors", IDS, 4, "crown").outfit, "")
	assert_eq(store.outfits(), ["crown"])


func test_award_on_full_page_gives_empty_sticker():
	for i in 3:
		store.award_sticker("colors", IDS, i)
	assert_eq(store.award_sticker("colors", IDS, 99).sticker, "")


func test_rounds_won_increments():
	assert_eq(store.rounds_won("colors"), 0)
	for i in 5:
		store.award_sticker("colors", IDS, i)
	assert_eq(store.rounds_won("colors"), 5)


func test_save_load_roundtrip():
	store.award_sticker("colors", IDS, 1, "crown")
	store.set_limit_minutes(15)
	store.set_timer_state({"date": "2026-10-19", "used_sec": 42.0, "bonus_sec": 0.0})
	store.save()
	var other := ProgressStore.new(PATH)
	other.load_or_default()
	assert_true(other.has_sticker("red"))
	assert_eq(other.rounds_won("colors"), 1)
	assert_eq(other.settings().limit_minutes, 15)
	assert_eq(other.timer_state().used_sec, 42.0)


func test_load_missing_file_gives_defaults():
	assert_eq(store.settings().limit_minutes, 0)
	assert_eq(store.outfits(), [])
	assert_eq(store.worn_outfit(), "")


func test_load_corrupt_file_gives_defaults():
	_write("{not json")
	var s := ProgressStore.new(PATH)
	s.load_or_default()
	assert_eq(s.settings().limit_minutes, 0)
	assert_false(s.has_sticker("red"))


func test_load_wrong_shape_gives_defaults():
	_write("[1, 2, 3]")
	var s := ProgressStore.new(PATH)
	s.load_or_default()
	assert_eq(s.rounds_won("colors"), 0)


func test_limit_rejects_other_values():
	store.set_limit_minutes(20)
	store.set_limit_minutes(7)
	assert_eq(store.settings().limit_minutes, 20)
	for m in [0, 10, 15, 20, 30]:
		store.set_limit_minutes(m)
		assert_eq(store.settings().limit_minutes, m)


func test_reset_keeps_settings():
	store.award_sticker("colors", IDS, 1, "crown")
	store.set_limit_minutes(10)
	store.set_worn_outfit("crown")
	store.reset_progress()
	assert_false(store.has_sticker("red"))
	assert_eq(store.rounds_won("colors"), 0)
	assert_eq(store.outfits(), [])
	assert_eq(store.worn_outfit(), "")
	assert_eq(store.settings().limit_minutes, 10)


func test_wear_only_owned_outfit():
	store.set_worn_outfit("crown")
	assert_eq(store.worn_outfit(), "")
	for i in 3:
		store.award_sticker("colors", IDS, i, "crown")
	store.set_worn_outfit("crown")
	assert_eq(store.worn_outfit(), "crown")
