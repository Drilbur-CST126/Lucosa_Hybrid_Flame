extends "res://Code/PlayerArea.gd"

export var animTime := 0.3

func _ready():
	var anim := $AnimationPlayer.get_animation("FadeIn") as Animation
	anim.track_set_key_time(0, 1, animTime)
	anim.length = animTime

func player_entered(_player: Node2D):
	$AnimationPlayer.play("FadeIn")
	
func player_exited(_player: Node2D):
	$AnimationPlayer.play_backwards("FadeIn")
