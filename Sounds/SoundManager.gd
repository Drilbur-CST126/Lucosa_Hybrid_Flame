extends Node2D

export(String, FILE, "*.json") var soundJson
export var volume := 1.0 setget set_volume

func set_volume(val: float):
	volume = val
	update_volume()

func update_volume():
	for sound in get_children():
		if sound is AudioStreamPlayer:
			sound.volume_db = linear2db(volume * GlobalData.sfxVolume)

func _ready():
	var file := File.new()
	Utility.print_errors([
		file.open(soundJson, File.READ),
		GlobalData.connect("sfx_volume_changed", self, "update_volume"),
	])
	var obj := parse_json(file.get_as_text()) as Dictionary
	for soundName in obj:
		var streamPlayer := AudioStreamPlayer.new()
		streamPlayer.stream = load(obj[soundName])
		streamPlayer.volume_db = linear2db(volume * GlobalData.sfxVolume)
		add_child(streamPlayer)
		streamPlayer.name = soundName

func play_sound(sound: String):
	var stream = get_node_or_null(sound)
	if stream == null:
		printerr("Error: Sound " + sound + " not found")
	else:
		stream.play()
