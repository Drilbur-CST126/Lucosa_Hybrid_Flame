extends Node2D

export var offset := 20.0

signal spell_hit(angle)
signal attack_hit(angle)

func _process(_delta):
#	var x := Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
#	var y := Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	var mousePos := get_global_mouse_position()
	var x := mousePos.x - global_position.x
	var y := mousePos.y - global_position.y
	
	if Input.is_action_just_pressed("spell"):
		emit_signal("spell_hit", $Sprite.rotation)
		
	if Input.is_action_just_pressed("attack"):
		emit_signal("attack_hit", $Sprite.rotation)
	
	if (x * x + y * y) > 0.3:
		var angle := atan2(y, x)
		$Sprite.rotation = angle
		$Sprite.position = Vector2(offset * cos(angle), offset * sin(angle))
