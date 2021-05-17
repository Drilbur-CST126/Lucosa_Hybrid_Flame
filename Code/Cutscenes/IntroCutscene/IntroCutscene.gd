extends Control

const TransitionEffect := preload("res://Code/Polish/TransitionEffect.tscn")

const kAnimShowoffs := {
	1: "ShowRuirui",
	2: "ShowCorruption",
	3: "ShowLucosa",
	5: "FadeOut",
}
const kStartRoom := "res://Stages/FrogLands/OpeningCutsceneRoom.tscn"
const kCharTimer := 0.03
const kDelayTimer := 1.0

export(String, FILE, "*.json") var dialoguePath

var dialogueArray: Array
var currentText := 0

func _ready():
	var file := File.new()
	Utility.print_errors([
		file.open(dialoguePath, File.READ),
		$CharacterTimer.connect("timeout", self, "increment_character_count"),
	])
	dialogueArray = parse_json(file.get_as_text())
	start_text_display(dialogueArray[0])
	$AnimationPlayer.play("Start")
	
func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		begin_transition()
	
func start_text_display(text: String):
	$IntroCutsceneTextbox.text = text
	$IntroCutsceneTextbox.visible_characters = 0
	$CharacterTimer.start(kCharTimer / (2.0 if Input.is_action_pressed("ui_accept") else 1.0))
	
func increment_character_count():
	var newChars: int = $IntroCutsceneTextbox.visible_characters + 1
	if newChars >= $IntroCutsceneTextbox.text.length():
		$DelayTimer.start(kDelayTimer / (2.0 if Input.is_action_pressed("ui_accept") else 1.0))
		yield($DelayTimer, "timeout")
		currentText += 1
		
		if currentText >= dialogueArray.size():
			begin_transition()
		else:
			play_anim()
			start_text_display(dialogueArray[currentText])
	else:
		$IntroCutsceneTextbox.visible_characters = newChars
		$CharacterTimer.start(kCharTimer / (2.0 if Input.is_action_pressed("ui_accept") else 1.0))
		
func play_anim():
	if kAnimShowoffs.keys().has(currentText):
		$AnimationPlayer.play(kAnimShowoffs[currentText])
		
func begin_transition():
	var effect := TransitionEffect.instance()
	effect.set_dimensions(rect_size.x, rect_size.y)
	effect.set_direction(GlobalData.Direction.Dtu)
	GlobalData.transDirection = GlobalData.Direction.Dtu
	Utility.print_errors([
		effect.connect("finished", self, "move_to_room"),
	])
	add_child(effect)
		
func move_to_room():
	GlobalData.lastRoomId = "IntroCutscene"
	Utility.print_errors([
		get_tree().change_scene(kStartRoom)
	])
