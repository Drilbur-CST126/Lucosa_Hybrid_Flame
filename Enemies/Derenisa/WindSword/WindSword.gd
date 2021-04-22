extends PlayerArea

const kFlySpeed := 312.0

var moving := false
var dest: Vector2
var marked_for_delete := false

func player_entered(playerNode: Node2D):
	var player := playerNode as Ruicosa
	player.knockback(null, 1)
	
func move_relative(offset: Vector2, mark_delete := false):
	move_to(global_position + offset, mark_delete)

func move_to(global_dest: Vector2, mark_delete := false):
	dest = global_dest
	rotation = global_position.angle_to_point(dest)
	moving = true
	marked_for_delete = mark_delete
	
func _process(delta: float):
	if moving:
		var leftToMove := (dest - global_position)
		var dir := leftToMove.angle()
		var velocity := leftToMove.normalized() * kFlySpeed
		global_position += velocity * delta
		if abs((dest - global_position).angle() - dir) > PI / 8.0: # Angle changed drastically; blade moved past target
			moving = false
			global_position = dest
			if marked_for_delete:
				queue_free()
