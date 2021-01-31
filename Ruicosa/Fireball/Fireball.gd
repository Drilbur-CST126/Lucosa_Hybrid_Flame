extends RigidBody2D

const Explosion := preload("res://Enemies/Explosion/Explosion.tscn")

func get_class() -> String:
	return "Fireball"

func _ready():
	Utility.print_connect_errors(get_path(), [
		$ExplosionTimer.connect("timeout", self, "explode"),
	])

func _process(_delta: float):
	var mod = 1.0 + cos($ExplosionTimer.time_left)
	$Visual/Glow.modulate = Color(mod, mod, mod)
	if $ExplosionTimer.time_left <= 0.2 && !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("Grow")
	
func explode():
	var explosion := Explosion.instance()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	queue_free()
