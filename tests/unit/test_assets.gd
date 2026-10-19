extends GutTest

const UI_IMAGES := ["momo", "star", "album", "lock", "arrow_left", "arrow_right", "learn", "play", "parent", "apple", "back",
	"outfit_crown", "outfit_top_hat", "outfit_cap", "outfit_sunglasses", "outfit_bow", "outfit_grad_cap",
	"outfit_flower", "outfit_helmet"]
const SFX := ["clap", "pop", "confetti", "whoosh", "boop"]


func before_all():
	ContentDB.require_assets = false


func _all_items() -> Array:
	var out := []
	for c in ContentDB.categories():
		out.append_array(ContentDB.items(c.id))
	return out


func test_every_emoji_item_has_image():
	for it in _all_items():
		if it.has("emoji"):
			assert_true(ResourceLoader.exists(ContentDB.image_path(it.id)), "image %s" % it.id)


func test_every_item_has_this_where_name_voice():
	for it in _all_items():
		for prefix in ["this_", "where_", "name_"]:
			assert_true(ResourceLoader.exists(ContentDB.voice_path(prefix + it.id)), prefix + it.id)


func test_every_category_has_cat_voice():
	for c in ContentDB.categories():
		assert_true(ResourceLoader.exists(ContentDB.voice_path("cat_" + c.id)), "cat_" + c.id)


func test_every_phrase_has_voice():
	for key in ContentDB.phrases().keys():
		assert_true(ResourceLoader.exists(ContentDB.voice_path(key)), key)


func test_ui_images_exist():
	for n in UI_IMAGES:
		assert_true(ResourceLoader.exists("res://assets/images/ui/%s.svg" % n), n)


func test_sfx_exist():
	for n in SFX:
		assert_true(ResourceLoader.exists("res://assets/audio/sfx/%s.ogg" % n), n)
