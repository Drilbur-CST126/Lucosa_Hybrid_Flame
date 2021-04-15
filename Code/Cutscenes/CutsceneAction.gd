extends Node2D
class_name CutsceneAction

var activated := false
var finished := false
onready var cutscene: Cutscene = get_parent() as Cutscene

signal finished()

func activate():
	activated = true
	
func is_finished() -> bool:
	return finished
	
func finish():
	activated = false
	finished = true
	emit_signal("finished")
