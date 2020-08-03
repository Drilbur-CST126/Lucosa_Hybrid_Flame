extends KinematicBody2D


enum ActionState {Normal, Jump, DoubleJump}


export var walkSpeed := 112.0
export var runSpeed := 192.0
export var maxSpeedTime := 0.5
export var maxGravityMultiplier := 4.0

export var jumpHeight := 6.0
export var minJumpHeight := 2.0
export var doubleJumpHeight := 3.0
export var jumpWidth := 10.0


var jumpImpulse: float
var doubleJumpImpulse: float
var gravity: float
var minJumpGravity: float
var jumpReleased := false

var velocity := Vector2()
var state = ActionState.Normal


func accelerate_to_velocity(delta: float, dest: float, speed: float = 0.0):
	if speed == 0.0:
		speed = abs(dest)
	var dir := sign(dest)
	if dest == 0.0:
		dir = sign(-velocity.x)
	velocity.x += dir * speed * delta / maxSpeedTime
	if (velocity.x < dest && dir < 0) || (velocity.x > dest && dir > 0):
		velocity.x = dest

func _ready():
	var jumpTime := jumpWidth * 4.0 / walkSpeed
	gravity = 2.0 * jumpHeight * 8.0 / (jumpTime * jumpTime)
	jumpImpulse = -gravity * jumpTime
	
	minJumpGravity = jumpImpulse * jumpImpulse / (16.0 * minJumpHeight)
	doubleJumpImpulse = -sqrt(16.0 * doubleJumpHeight * gravity)
	
func _physics_process(delta):
	var curGravity = gravity
	if jumpReleased && state == ActionState.Jump && velocity.y < 0.0:
		curGravity = minJumpGravity
	velocity.y += curGravity * delta
	if velocity.y > gravity * maxGravityMultiplier:
		velocity.y = gravity * maxGravityMultiplier
		
	if Input.is_action_pressed("ui_left"):
		accelerate_to_velocity(delta, -walkSpeed)
	elif Input.is_action_pressed("ui_right"):
		accelerate_to_velocity(delta, walkSpeed)
	else:
		accelerate_to_velocity(delta, 0.0, walkSpeed)
		
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
	if is_on_floor() && state == ActionState.Jump || state == ActionState.DoubleJump:
		state = ActionState.Normal
