extends KinematicBody2D

const kSpeed := 160.0

var angle: float

func _process(delta):
	var vel := -kSpeed * Vector2(cos(angle), sin(angle))
	var col := move_and_collide(vel * delta)
	if col != null:
		var collider := col.collider
		if collider is Ruicosa:
			collider.knockback(self, 1, false)
		queue_free()
