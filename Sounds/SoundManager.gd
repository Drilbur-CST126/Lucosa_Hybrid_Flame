extends Node2D

export(String, FILE, "*.json") var soundJson
export var volumeDb := 0.0

func _ready():
	var file := File.new()
	Utility.print_errors([
		file.open(soundJson, File.READ),
	])
	var obj := parse_json(file.get_as_text()) as Dictionary
	for soundName in obj:
		var streamPlayer := AudioStreamPlayer.new()
		streamPlayer.stream = load(obj[soundName])
		streamPlayer.volume_db = volumeDb
		add_child(streamPlayer)
		streamPlayer.name = soundName

func play_sound(sound: String):
	var stream = get_node_or_null(sound)
	if stream == null:
		printerr("Error: Sound " + sound + " not found")
	else:
		stream.play()
