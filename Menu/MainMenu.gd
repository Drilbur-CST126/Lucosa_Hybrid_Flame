extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass
	GlobalData.print_errors([
		$OptionVBoxContainer/NewGame.connect("pressed", get_tree(), "change_scene", ["res://Stages/FrogLands/JumpTutorialRoom.tscn"]),
		$OptionVBoxContainer/Continue.connect("pressed", GlobalData, "load_game"),
		$OptionVBoxContainer/Exit.connect("pressed", get_tree(), "quit"),
	])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
