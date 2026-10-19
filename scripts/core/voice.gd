extends Node
## Autoload "Voice": one voice line at a time, plus short sound effects.
## A missing file is skipped with a warning so the game never stops on it.

signal finished

var _voice := AudioStreamPlayer.new()
var _sfx: Array[AudioStreamPlayer] = []
var _cache := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_voice)
	_voice.finished.connect(func(): finished.emit())
	for i in 3:
		var p := AudioStreamPlayer.new()
		p.volume_db = -4.0
		add_child(p)
		_sfx.append(p)


func play(key: String) -> void:
	var stream := _load(ContentDB.voice_path(key))
	_voice.stop()
	if stream == null:
		finished.emit()
		return
	_voice.stream = stream
	_voice.play()


func play_sfx(sfx_name: String) -> void:
	var stream := _load("res://assets/audio/sfx/%s.ogg" % sfx_name)
	if stream == null:
		return
	for p in _sfx:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	_sfx[0].stream = stream
	_sfx[0].play()


func stop() -> void:
	_voice.stop()


func is_playing() -> bool:
	return _voice.playing


func _load(path: String) -> AudioStream:
	if _cache.has(path):
		return _cache[path]
	var stream: AudioStream = null
	if ResourceLoader.exists(path):
		stream = load(path)
	else:
		push_warning("Voice: missing %s" % path)
	_cache[path] = stream
	return stream
