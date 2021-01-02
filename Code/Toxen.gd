extends KinematicBody2D
class_name Toxen

const Enemy = preload("res://Code/Enemy.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var gravity := 1024.0
export var jumpVelocity := 256.0
export var jumpHeight := 48.0
export var uppercutVelocity := 256.0
export var coyoteTime : = 0.1
export var walkSpeed := 112.0
export var runSpeed := 192.0
export var runAcceleration := 2048.0
export var knockbackSpeed := 64.0
export var attackHitbox := Vector2(5.0, 10.0)
export var uppercutHitbox := Vector2(2.0, 10.0)
export var attackDmg := 2

var velocity: Vector2 = Vector2(0.0, 0.0)
var canJump: bool = false
var onGround: bool = false
var amountJumped: float = 0.0
var coyoteTimeGranted: float = 0.0
var attacking: bool = false
var running := false
var canMove := true
var canUppercut := false
var uppercutting := false
var animConnected := false

signal hit_ground()

func get_class() -> String:
	return "Toxen"

func _set_can_move(val: bool):
	canMove = val
	
func _setAttackHitbox(bound: Vector2):
	$AttackArea/CollisionShape2D.shape.extents = bound
	$AttackArea.position.x = (1 if $AnimatedSprite.flip_h else -1) * (3 + bound.x)

func _ready():
	#Engine.time_scale = 0.2
	look_left()
	$AttackArea.connect("body_entered", self, "_basic_attack")
	$StunTumer.connect("timeout", self, "_set_can_move", [true])
	$AttackArea/CollisionShape2D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("attack") && !attacking:
		var anim = "smol_attack_1"
		if $AnimatedSprite.animation == "smol_attack_1":
			anim = "smol_attack_2"
		$AnimatedSprite.play("default")
		$AnimatedSprite.play(anim)
		if animConnected:
			$AnimTimer.disconnect("timeout", $AnimatedSprite, "play")
		$AnimTimer.connect("timeout", $AnimatedSprite, "play", ["default"])
		animConnected = true
		$AnimTimer.start(0.7)
		attacking = true
		_setAttackHitbox(attackHitbox)
		$AttackArea/CollisionShape2D.disabled = false
		yield(Utility.create_timer(self,0.3), "timeout")
		$AttackArea/CollisionShape2D.disabled = true
		#yield(Utility.create_timer(self,0.2), "timeout")
		attacking = false

func _physics_process(delta):
	_process_x_velocity(delta)
	_process_y_velocity(delta)
	velocity = move_and_slide(velocity, Vector2.UP, true)
	#OS.delay_msec(20)

func _process_x_velocity(delta):
	if canMove:
		if onGround:
			running = Input.is_action_pressed("run")
		var movespeed := runSpeed if running else walkSpeed
	
		var moving: bool = false
		if Input.is_action_pressed("ui_left"):
			velocity.x -= runAcceleration * delta
			#velocity.x = -runSpeed
			moving = true
			if velocity.x < -movespeed:
				velocity.x = -movespeed
		if Input.is_action_pressed("ui_right"):
			velocity.x += runAcceleration * delta
			#velocity.x = runSpeed
			moving = true
			if velocity.x > movespeed:
				velocity.x = movespeed
		
		if !moving:
			if $AnimatedSprite.animation == "run":
				$AnimatedSprite.play("default")
			if velocity.x < 0.0:
				velocity.x += runAcceleration * delta
				#velocity.x = 0.0
				if velocity.x > 0.0:
					velocity.x = 0.0
			if velocity.x > 0.0:
				velocity.x -= runAcceleration * delta
				#velocity.x = 0.0
				if velocity.x < 0.0:
					velocity.x = 0.0
		elif $AnimatedSprite.animation == "default":
			$AnimatedSprite.play("run")
		
		if velocity.x < 0.0 && $AnimatedSprite.flip_h:
			look_left()
		if velocity.x > 0.0 && !$AnimatedSprite.flip_h:
			look_right()

func look_left():
	$AnimatedSprite.flip_h = false
	$AnimatedSprite.offset.x = -2

func look_right():
	$AnimatedSprite.flip_h = true
	$AnimatedSprite.offset.x = 1

func _process_y_velocity(delta):
	velocity.y += gravity * delta
	#print(velocity.y)
	if !Input.is_action_pressed("jump"):
		coyoteTimeGranted -= delta
	
	if is_on_floor() && !Input.is_action_pressed("jump"):
		if !onGround:
			emit_signal("hit_ground")
		canJump = true
		canUppercut = GlobalData.hasUppercut
		onGround = true
		coyoteTimeGranted = coyoteTime
		#velocity.y = 0.0
	else:
		onGround = false
		if canJump && coyoteTimeGranted <= 0.0:
			canJump = false
		
	if canJump && Input.is_action_pressed("jump"):
		velocity.y = -jumpVelocity
		#print("Jumpe")
		if test_move(transform, Vector2(0.0, velocity.y * delta)):
			canJump = false
		else:
			if Input.is_action_just_pressed("jump"):
				amountJumped = 0.0
			amountJumped -= velocity.y * delta
			if amountJumped >= jumpHeight:
				velocity.y /= 2.0
				canJump = false
				
	if !canJump && canUppercut && Input.is_action_just_pressed("jump"):
		velocity.y = -uppercutVelocity
		uppercutting = true
		canUppercut = false
		_setAttackHitbox(uppercutHitbox)
		$AttackArea/CollisionShape2D.disabled = false
		yield(Utility.create_timer(self,0.05), "timeout")
		$AttackArea/CollisionShape2D.disabled = true
		uppercutting = false
				
	if canJump && Input.is_action_just_released("jump"):
		velocity.y /= 2.0
		canJump = false
		
func _basic_attack(other: Node):
	if other.has_node("EnemyData"):
		var enemyData: Enemy = other.get_node("EnemyData")
		enemyData.take_damage(attackDmg)
		if uppercutting:
			canUppercut = true
			
func look_at(pos: Vector2):
	if position.x > pos.x:
		look_left()
	else:
		look_right()
			
func knockback():
	if $AnimatedSprite.flip_h:
		velocity.x = -knockbackSpeed
	else:
		velocity.x = knockbackSpeed
	velocity.y = -jumpVelocity
	amountJumped = jumpHeight - 24
	canMove = false
	$StunTumer.start()
