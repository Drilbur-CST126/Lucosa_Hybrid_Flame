extends Node2D

export var specialFlag := ""

var openFlag: String

# Called when the node enters the scene tree for the first time.
func _ready():
	openFlag = String(get_path()) + "_open" + specialFlag
	if GlobalData.flags.has(openFlag):
		queue_free()

func open():
	$AnimationPlayer.play("Open")
	GlobalData.flags.append(openFlag)
	yield($AnimationPlayer, "animation_finished")
	queue_free()
