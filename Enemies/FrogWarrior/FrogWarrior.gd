extends KinematicBody2D

const FrogSword1 = preload("res://Graphics/Particles/FrogSword1/FrogSword1.tscn")

const kWalkSpeed := 48.0
const kRunSpeed := 64.0
const kMaxRunSpeed := 128.0
const kAcceleration := 512.0
const kJumpHeight := 3.0
const kPlayerSightRange := 50.0
const kPlayerAttackRange := 16.0
const kMaxSpeedDist := 128.0

const kAnimOffsets := {
	"Walk" : 0,
	"Run" : 0,
	"Shock" : 4,
	"Attack": 4,
	"Strike": 6,
}

export var facingRight := true

var velocity := Vector2(kWalkSpeed, 0.0)
var jumpImpulse: float
var moving := true

var target: Node2D = null
var hasTarget := false
var canAttack := true

func set_facing_right(val: bool):
	facingRight = val
	var dir = get_dir()
	$GroundRayCast.position.x = 8 * dir
	$VisionRayCast.position.x = 8 * dir
	$VisionRayCast.cast_to.x = kPlayerSightRange * dir
	$AnimatedSprite.flip_h = val
	$AnimatedSprite.offset.x = kAnimOffsets[$AnimatedSprite.animation] * dir
	if !hasTarget:
		velocity.x = kWalkSpeed * dir
		
func get_dir() -> int:
	return 1 if facingRight else -1
	
func get_target_dist() -> float:
	if target == null:
		return 0.0
	else:
		return abs(target.global_position.x - global_position.x)
		
func get_run_speed() -> float:
	return lerp(kRunSpeed, kMaxRunSpeed, get_target_dist() / kMaxSpeedDist)
	
func set_target(newTarget: Node2D):
	target = newTarget
	hasTarget = true
	$GroundRayCast.enabled = false
	$VisionRayCast.cast_to.x = kPlayerAttackRange * get_dir()
	play_anim("Shock")
	jumpImpulse = -sqrt(16.0 * kJumpHeight * GlobalData.gravity)
	
	moving = false
	$StunTimer.start(0.5)
	yield($StunTimer, "timeout")
	moving = true
	play_anim("Run")
	
func play_anim(anim: String):
	$AnimatedSprite.play(anim)
	$AnimatedSprite.offset.x = kAnimOffsets[$AnimatedSprite.animation] * get_dir()
		
func handle_walk():
	if !$GroundRayCast.is_colliding() || is_on_wall():
		set_facing_right(!facingRight)
			
	if $VisionRayCast.is_colliding() \
		&& $VisionRayCast.get_collider().get_class() == GlobalData.kPlayerClassName \
		&& GlobalData.lucosaForm:
			set_target($VisionRayCast.get_collider())
		
func handle_chase(delta: float):
	var playerOnRight := target.global_position.x > global_position.x
	if facingRight != playerOnRight:
		set_facing_right(!facingRight)
	
	var dir = get_dir()
	velocity.x *= dir
	var runSpeed = get_run_speed()
	if velocity.x < runSpeed:
		velocity.x += kAcceleration * delta
	else:
		velocity.x = runSpeed
	velocity.x *= dir
	
	if canAttack && $VisionRayCast.is_colliding() \
		&& $VisionRayCast.get_collider().get_class() == GlobalData.kPlayerClassName:
			attack()
	
func attack():
	moving = false
	canAttack = false
	play_anim("Attack")
	$AttackCooldownTimer.start()
	yield(Utility.create_timer(self,0.55), "timeout")
	play_anim("Strike")
	var attack := FrogSword1.instance()
	var dir := get_dir()
	#attack.get_node("ParticleSprite").velocity *= dir
	#attack.get_node("ParticleSprite").velocity_random *= dir
	#attack.get_node("ParticleSprite").acceleration *= dir
	#attack.position.x = 8.0 * dir
	attack.scale.x = -dir
	#attack.hide()
	add_child(attack)
	yield(Utility.create_timer(self,0.3), "timeout")
	play_anim("Run")
	moving = true
	yield($AttackCooldownTimer, "timeout")
	canAttack = true
	
func on_damage():
	moving = false
	$StunTimer.start(0.3)
	yield($StunTimer, "timeout")
	moving = true
		
func _ready():
	$GroundRayCast.force_raycast_update()
	global_position.y = $GroundRayCast.get_collision_point().y - $GroundRayCast.position.y
	$GroundRayCast.cast_to.y = 2
	
	set_facing_right(facingRight)
	
	Utility.print_connect_errors(get_path(), [
		$EnemyData.connect("on_hit", self, "on_damage"),
	])
	
	play_anim("Walk")

func _physics_process(delta):
	if moving:
		velocity.y += GlobalData.gravity * delta
		
		if !hasTarget:
			handle_walk()
		else:
			handle_chase(delta)
		
		velocity = move_and_slide(velocity, Vector2.UP, true)
