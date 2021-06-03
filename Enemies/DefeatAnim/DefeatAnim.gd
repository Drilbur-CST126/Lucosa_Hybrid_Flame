extends Node2D

func _ready():
	Utility.print_errors([
		$AnimationPlayer.connect("animation_finished", self, "anim_finished"),
	])
	
func anim_finished(_anim):
	queue_free()
	
