extends GutTest


func before_all():
	ContentDB.require_assets = false


func _all_items() -> Array:
	var out := []
	for c in ContentDB.categories():
		out.append_array(ContentDB.items(c.id))
	return out


func test_eight_categories_in_order():
	var ids := []
	for c in ContentDB.categories():
		ids.append(c.id)
	assert_eq(ids, ["colors", "numbers_1", "numbers_2", "animals", "sea_animals", "reptiles", "flowers", "body_parts"])


func test_item_ids_globally_unique():
	var seen := {}
	for it in _all_items():
		assert_false(seen.has(it.id), "duplicate id %s" % it.id)
		seen[it.id] = true


func test_each_item_has_exactly_one_kind():
	for it in _all_items():
		var kinds := 0
		for k in ["emoji", "color", "number"]:
			if it.has(k):
				kinds += 1
		assert_eq(kinds, 1, "item %s" % it.id)


func _numbers(cat: String) -> Array:
	var out := []
	for it in ContentDB.items(cat):
		out.append(int(it.number))
	return out


func test_numbers_1_is_one_to_ten():
	assert_eq(_numbers("numbers_1"), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])


func test_numbers_2_is_eleven_to_twenty():
	assert_eq(_numbers("numbers_2"), [11, 12, 13, 14, 15, 16, 17, 18, 19, 20])


func test_avoid_with_refers_to_same_category_ids():
	for c in ContentDB.categories():
		var ids := []
		for it in ContentDB.items(c.id):
			ids.append(it.id)
		for it in ContentDB.items(c.id):
			for other in it.get("avoid_with", []):
				assert_has(ids, other, "%s avoid_with %s" % [it.id, other])


func test_every_category_has_outfit_and_icon_item_exists():
	for c in ContentDB.categories():
		assert_ne(str(c.get("outfit", "")), "", c.id)
		assert_false(ContentDB.item(c.icon_item).is_empty(), "icon_item of %s" % c.id)


func test_each_category_has_at_least_3_items():
	for c in ContentDB.categories():
		assert_gte(ContentDB.items(c.id).size(), 3, c.id)


func test_paths():
	assert_eq(ContentDB.voice_path("this_red"), "res://assets/audio/voice/this_red.ogg")
	assert_eq(ContentDB.image_path("cat"), "res://assets/images/items/cat.svg")
