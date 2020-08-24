extends KinematicBody2D


enum ActionState {Normal, Falling, Jump, DoubleJump, Jab, Dive, Knockback}


export var walkSpeed := 112.0
export var runSpeed := 192.0
export var maxSpeedTime := 0.5
export var maxGravityMultiplier := 4.0
export var knockbackSpeed := 64.0

export var jumpHeight := 6.0
export var minJumpHeight := 2.0
export var doubleJumpHeight := 3.0
export var jumpWidth := 10.0

export var jabXVelocity := 384.0
export var diveVelocity := 256.0

var jumpImpulse: float
var doubleJumpImpulse: float
var gravity: float
var minJumpGravity: float
var jumpReleased := false
var canDoubleJump := false
var facingRight := true setget set_facing_right

var velocity := Vector2()
var state = ActionState.Normal


func get_class():
	return "Ruicosa"
	
func look_at(pos: Vector2):
	self.facingRight = pos.x > position.x
	
func knockback():
	if state == ActionState.Dive:
		if facingRight:
			velocity.x = -walkSpeed
		else:
			velocity.x = walkSpeed
		velocity.y = jumpImpulse
		state = ActionState.Normal
		canDoubleJump = true
	else:
		if facingRight:
			velocity.x = -knockbackSpeed
		else:
			velocity.x = knockbackSpeed
		velocity.y = jumpImpulse / 2.0
		state = ActionState.Knockback

func set_facing_right(value: bool):
	facingRight = value
	$Sprite.flip_h = value
	$Sprite.offset.x = 20.0 if value else -20.0
	
func play_anim(anim: String):
	$Sprite.play(anim)
	$Sprite.offset.x = 20.0 if facingRight else -20.0
	$Sprite.offset.x *= -1 if anim == "Run" else 1

func accelerate_to_velocity(delta: float, dest: float, speed: float = 0.0):
	if speed == 0.0:
		speed = abs(dest)
	var dir := sign(dest)
	if dest == 0.0:
		dir = sign(-velocity.x)
		
	var velocityChange := dir * speed * delta / maxSpeedTime
	if !(velocity.x < dest && dir < 0) && !(velocity.x > dest && dir > 0):
		velocity.x += velocityChange
		if (velocity.x < dest && dir < 0) || (velocity.x > dest && dir > 0):
			velocity.x = dest
	else:
		velocity.x -= velocityChange
		
func jab(angle: float):
	#velocity.x = -sign(cos(angle)) * jabXVelocity * sqrt(abs(cos(angle)))
	($Attack/CollisionShape2D.shape as RectangleShape2D).extents.x = 15
	($Attack/CollisionShape2D.shape as RectangleShape2D).extents.y = 4
	$Attack/CollisionShape2D.position.x = 15
	$Attack.rotation = angle
	$Attack/CollisionShape2D.disabled = false
	if ($Attack.connect("body_entered", self, "jab_connect", [angle])):
		print("Jab connect failed!")
	yield(get_tree().create_timer(0.1), "timeout")
	$Attack.disconnect("body_entered", self, "jab_connect")
	$Attack/CollisionShape2D.disabled = true
	
func jab_connect(source: Node2D, angle: float):
	print("Hit!")
	if (source.has_node("EnemyData")):
		velocity.x = -jabXVelocity * cos(angle)
		velocity.y = sign(sin(angle)) * jumpImpulse * sqrt(abs(sin(angle)))
		self.facingRight = cos(angle) > 0.0
		state = ActionState.Jab
		canDoubleJump = true
		$Attack/CollisionShape2D.set_deferred("disabled", true)
	
func dive():
	if state != ActionState.Dive && is_air_state():
		#self.facingRight = cos(angle) < 0.0
		velocity.x = (1 if facingRight else -1) * diveVelocity
		velocity.y = knockbackSpeed if Input.is_action_pressed("ui_down") else 0.0
		state = ActionState.Dive
	
func is_air_state():
	return state == ActionState.Falling || state == ActionState.Jump || state == ActionState.DoubleJump || state == ActionState.Jab || state == ActionState.Dive || state == ActionState.Knockback
	
func is_momentum_state():
	return state == ActionState.Dive || state == ActionState.Knockback

func _ready():
	var jumpTime := jumpWidth * 4.0 / walkSpeed
	gravity = 2.0 * jumpHeight * 8.0 / (jumpTime * jumpTime)
	jumpImpulse = -gravity * jumpTime
	
	minJumpGravity = jumpImpulse * jumpImpulse / (16.0 * minJumpHeight)
	doubleJumpImpulse = -sqrt(16.0 * doubleJumpHeight * gravity)
	
#	$AimReticle.connect("spell_hit", self, "jab")
#	$AimReticle.connect("attack_hit", self, "dive")
	
func _physics_process(delta):
	var curGravity = gravity
	if jumpReleased && state == ActionState.Jump && velocity.y < 0.0:
		curGravity = minJumpGravity
	velocity.y += curGravity * delta
	if velocity.y > gravity * maxGravityMultiplier:
		velocity.y = gravity * maxGravityMultiplier
		
	if !is_momentum_state():
		var curSpeed = walkSpeed
		if Input.is_action_pressed("ui_left"):
			accelerate_to_velocity(delta, -curSpeed)
			self.facingRight = false
			play_anim("Run")
		elif Input.is_action_pressed("ui_right"):
			accelerate_to_velocity(delta, curSpeed)
			self.facingRight = true
			play_anim("Run")
		else:
			accelerate_to_velocity(delta, 0.0, curSpeed)
			play_anim("default")

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jumpImpulse
			state = ActionState.Jump
		elif canDoubleJump:
			velocity.y = doubleJumpImpulse
			state = ActionState.DoubleJump
			canDoubleJump = false
		
		jumpReleased = false
	
	if Input.is_action_just_released("jump"):
		jumpReleased = true
		
	if Input.is_action_just_pressed("attack"):
		dive()
		
	velocity = move_and_slide(velocity, Vector2.UP, true)
	if is_on_floor() && is_air_state():
		state = ActionState.Normal
		canDoubleJump = true
		
	if !is_on_floor() && state == ActionState.Normal:
		state = ActionState.Falling
