extends KinematicBody2D

const kMovespeed := 64.0
const kHitbox := 6.0

export var facingRight := false
export var standing := false

var moving := true
var velocity: Vector2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_facing_right(value: bool):
	facingRight = value
	var dir = 1 if facingRight else -1
	$RayCast2D.position.x = kHitbox * dir
	$AnimatedSprite.flip_h = value
	velocity = Vector2(kMovespeed * dir, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_facing_right(facingRight)
	Utility.print_connect_errors(get_path(), [
		$EnemyData.connect("on_hit", self, "on_damage"),
		$StunTimer.connect("timeout", self, "stun_timer_finish"),
	])

func _physics_process(_delta):
	if moving && !standing:
		velocity = move_and_slide(velocity)
		if !$RayCast2D.is_colliding() || is_on_wall():
			set_facing_right(!facingRight)
		
func on_damage(_source):
	moving = false
	$StunTimer.start()

func stun_timer_finish():
	moving = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
