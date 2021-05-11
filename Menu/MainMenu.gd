extends Node2D

func _ready():
	#pass
	Utility.print_connect_errors(get_path(), [
		$OptionVBoxContainer/NewGame.connect("pressed", self, "new_game"),
		$OptionVBoxContainer/Continue.connect("pressed", self, "load_game"),
		$OptionVBoxContainer/Exit.connect("pressed", get_tree(), "quit"),
	])
	$OptionVBoxContainer/NewGame.grab_focus()
	$AnimationPlayer.play("Load")
	
const newGameScene := "res://Stages/FrogLands/JumpTutorialRoom.tscn"
func new_game():
	GlobalData.reset()
	GlobalData.debug = false
	Utility.print_errors([
		get_tree().change_scene(newGameScene),
	])
	GlobalData.save_reload(newGameScene)
	
func load_game():
	GlobalData.reset()
	GlobalData.debug = false
	var success := GlobalData.load_game()
	if !success:
		new_game()
