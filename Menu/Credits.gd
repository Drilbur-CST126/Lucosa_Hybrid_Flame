extends Control

const kScrollSpeed := 128.0
const kRooms := 59
const kPercentPerRoom := 30.0 / kRooms
const kPercentPerAbility := 40.0 / 6
const kPercentPerOptional := 30.0 / 9

var creditsSize: float
var done := false

func get_completion_percent() -> int:
	var percent := 0.0
	
	var roomDict := Dictionary()
	for room in GlobalData.roomsVisited:
		roomDict[room] = true
	percent += roomDict.keys().size() * kPercentPerRoom
	
	for ability in GlobalData.Ability.values():
		if GlobalData.has_ability(ability):
			percent += kPercentPerAbility
			
	percent += kPercentPerOptional * (GlobalData.maxCharges + GlobalData.playerForesight \
			+ GlobalData.playerMaxHp - GlobalData.kPlayerStartingMaxHp)
	
	return int(round(percent))
	
func get_play_time() -> String:
	var timePlayed := GlobalData.timePlayed
	var hours := floor(timePlayed / 3600)
	var minutes := floor((timePlayed - hours * 3600) / 60)
	var seconds := floor(timePlayed - hours * 3600 - minutes * 60)
	
	if hours > 0.0:
		return String(hours) + " Hours, " + String(minutes) + " Minutes, " + String(seconds) + " Seconds"
	elif minutes > 0.0:
		return String(minutes) + " Minutes, " + String(seconds) + " Seconds"
	return String(seconds) + " Seconds"
	
func _ready():
	get_tree().paused = false
	$Credits/CompletionPercent.text = "\nCompletion %: " + String(get_completion_percent()) + "%"
	$Credits/PlayTime.text = "\nPlay time: " + get_play_time()
	creditsSize = $Credits.rect_size.y
	
func _process(delta):
	if $Credits.rect_position.y > -(creditsSize - rect_size.y):
		$Credits.rect_position.y -= kScrollSpeed * delta
	else:
		done = true
		
func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton) && done:
		get_tree().change_scene("res://Menu/MainMenu.tscn")
