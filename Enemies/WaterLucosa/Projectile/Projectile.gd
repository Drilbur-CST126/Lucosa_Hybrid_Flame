extends KinematicBody2D

var kMaxSpeed := 96.0
var kRotAcceleration := deg2rad(150.0)

var velocity := Vector2.ZERO
var target: Node2D

func _ready():
	Utility.print_errors([
		$EnemyData.connect("on_touch", self, "on_touch"),
		$EnemyData.connect("on_death", self, "destroy"),
		$DurationTimer.connect("timeout", self, "destroy")
	])
	
func _physics_process(delta: float):
	var angleToTarget := velocity.angle_to((target.global_position - global_position))
	var angle := velocity.angle()
	var rotVelocityChange := kRotAcceleration * delta
	if angleToTarget > rotVelocityChange:
		angle += rotVelocityChange
	elif angleToTarget < -rotVelocityChange:
		angle -= rotVelocityChange
	else:
		angle = (target.global_position - global_position).angle()
		
	velocity = Vector2(kMaxSpeed * cos(angle), kMaxSpeed * sin(angle))
	velocity = move_and_slide(velocity)
	
func focus_on_target():
	velocity = (target.global_position - global_position).normalized() * kMaxSpeed
	
func on_touch(other: Node2D):
	if other is Ruicosa:
		destroy()
	
func destroy():
	if has_node("EnemyData"):
		$EnemyData.queue_free()
	$Circle.hide()
	$Particles2D.emitting = true
	$DestroyAnimTimer.start()
	yield($DestroyAnimTimer, "timeout")
	queue_free()
