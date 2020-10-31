extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	Utility.print_connect_errors(get_path(), [
		$OptionVBoxContainer/NewGame.connect("pressed", self, "new_game"),
		$OptionVBoxContainer/Continue.connect("pressed", GlobalData, "load_game"),
		$OptionVBoxContainer/Exit.connect("pressed", get_tree(), "quit"),
	])
	$OptionVBoxContainer/NewGame.grab_focus()
	$AnimationPlayer.play("Load")
	
const newGameScene := "res://Stages/FrogLands/JumpTutorialRoom.tscn"
func new_game():
	get_tree().change_scene(newGameScene)
	GlobalData.save_reload(newGameScene)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
