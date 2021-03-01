extends KinematicBody2D

const Explosion := preload("res://Enemies/Explosion/Explosion.tscn")

const kKnockbackVelocity := 96.0
const kGravity := 128.0

var exploding := false
var velocity := Vector2.ZERO

func _ready():
	Utility.print_errors([
		$EnemyData.connect("on_hit", self, "begin_explosion"),
		$ExplosionTimer.connect("timeout", self, "explode")
	])
	
func _physics_process(delta):
	if !exploding:
		velocity = 5 * Vector2(0.0, cos(2 * PI * $VibrateTimer.time_left / $VibrateTimer.wait_time))
	else:
		velocity.y += kGravity * delta
		
	velocity = move_and_slide(velocity)
	
func begin_explosion(source: Node2D):
	$EnemyData.queue_free()
	exploding = true
	var direction := 0
	if source is Ruicosa:
		direction = Utility.get_dir(source.facingRight)
	else:
		direction = Utility.get_dir(source.position.x < position.x)
	velocity = Vector2(direction * kKnockbackVelocity, 0.0)
	$ExplosionTimer.start()
	
func explode():
	var explosion := Explosion.instance() as Node2D
	explosion.position = position
	get_parent().add_child(explosion)
	queue_free()
