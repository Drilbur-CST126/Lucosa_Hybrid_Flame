extends KinematicBody2D


enum ActionState {Normal, Jump, DoubleJump, Jab, Dive}


export var walkSpeed := 112.0
export var runSpeed := 192.0
export var maxSpeedTime := 0.5
export var maxGravityMultiplier := 4.0

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
var facingRight := true setget set_facing_right

var velocity := Vector2()
var state = ActionState.Normal


func set_facing_right(value: bool):
	facingRight = value
	$Sprite.flip_h = value
	$Sprite.offset.x = 2.0 if value else -2.0

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
	velocity.x = -jabXVelocity * cos(angle)
	velocity.y = sign(sin(angle)) * jumpImpulse * sqrt(abs(sin(angle)))
	self.facingRight = cos(angle) > 0.0
	state = ActionState.Jab
	
func dive(angle: float):
	if is_air_state():
		self.facingRight = cos(angle) < 0.0
		velocity.x = (1 if facingRight else -1) * diveVelocity
		velocity.y = 0.0
		state = ActionState.Dive
	
func is_air_state():
	return state == ActionState.Jump || state == ActionState.DoubleJump || state == ActionState.Jab || state == ActionState.Dive
	
func is_momentum_state():
	return state == ActionState.Dive

func _ready():
	var jumpTime := jumpWidth * 4.0 / walkSpeed
	gravity = 2.0 * jumpHeight * 8.0 / (jumpTime * jumpTime)
	jumpImpulse = -gravity * jumpTime
	
	minJumpGravity = jumpImpulse * jumpImpulse / (16.0 * minJumpHeight)
	doubleJumpImpulse = -sqrt(16.0 * doubleJumpHeight * gravity)
	
	$AimReticle.connect("spell_hit", self, "jab")
	$AimReticle.connect("attack_hit", self, "dive")
	
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
		elif Input.is_action_pressed("ui_right"):
			accelerate_to_velocity(delta, curSpeed)
			self.facingRight = true
		else:
			accelerate_to_velocity(delta, 0.0, curSpeed)

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jumpImpulse
			state = ActionState.Jump
		else:
			velocity.y = doubleJumpImpulse
			state = ActionState.DoubleJump
		
		jumpReleased = false
	
	if Input.is_action_just_released("jump"):
		jumpReleased = true
		
	velocity = move_and_slide(velocity, Vector2.UP, true)
	if is_on_floor() && is_air_state():
		state = ActionState.Normal
