extends PlayerArea

const kFlySpeed := 384.0

var moving := false
var dest: Vector2

func player_entered(playerNode: Node2D):
	var player := playerNode as Ruicosa
	player.knockback(null, 1)
	
func move_relative(offset: Vector2):
	move_to(global_position + offset)

func move_to(global_dest: Vector2):
	dest = global_dest
	rotation = global_position.angle_to_point(dest)
	moving = true
	
func _process(delta: float):
	if moving:
		var leftToMove := (dest - global_position)
		var dir := leftToMove.angle()
		var velocity := leftToMove.normalized() * kFlySpeed
		global_position += velocity * delta
		if abs((dest - global_position).angle() - dir) > PI / 8.0: # Angle changed drastically; blade moved past target
			moving = false
			global_position = dest
