extends Node2D

func _ready():
	global_position = OS.window_size - Vector2(200, 50)
	Utility.print_errors([
		$AnimationPlayer.connect("animation_finished", self, "anim_finished"),
	])
	
func anim_finished(_anim):
	queue_free()
