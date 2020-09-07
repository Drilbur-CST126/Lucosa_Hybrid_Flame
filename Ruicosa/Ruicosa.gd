extends KinematicBody2D


const HUD = preload("res://Code/HUD.tscn")
const Enemy = preload("res://Code/Enemy.gd")
const HIT_1 = preload("res://Graphics/Particles/Hit1/Hit1.tscn")
const UPPERCUT = preload("res://Graphics/Particles/Uppercut/Uppercut.tscn")


enum ActionState {
	Normal, 
	Falling, 
	Jump, 
	DoubleJump, 
	Jab, 
	Dive, 
	Knockback,
	Transforming
}


const animOffsets := {
	"Idle": -20,
	"Run": 20,
	"Transform": -20,
	"Lucosa_Idle": -20,
	"Lucosa_Run": -20,
}

const walkSpeed := 128.0
const runSpeed := 192.0
const maxSpeedTime := 0.15
const maxGravityMultiplier := 4.0
const knockbackSpeed := 64.0

const jumpHeight := 6.0
const minJumpHeight := 2.5
const doubleJumpHeight := 2.5
const lucosaJumpHeight := 4.0
const jumpWidth := 10.0

const diveVelocity := 256.0

var jumpImpulse: float
var doubleJumpImpulse: float
var lucosaJumpImpulse: float
var gravity: float
var minJumpGravity: float
var jumpReleased := false
var canDoubleJump := false
var facingRight := true setget set_facing_right
var lucosaForm := false setget set_lucosa_form

var canAttack := true
var attackDmg := 2

var velocity := Vector2()
var state = ActionState.Normal


signal formSwap(form)


func get_class():
	return "Ruicosa"
	
func look_at(pos: Vector2):
	self.facingRight = pos.x > position.x
	
func knockback(damage := 0):
	if state == ActionState.Dive:
		if facingRight:
			velocity.x = -walkSpeed
		else:
			velocity.x = walkSpeed
		velocity.y = jumpImpulse
		state = ActionState.Normal
		canDoubleJump = true
	else:
		if (damage > 0):
			GlobalData.playerHp -= damage
		
		if facingRight:
			velocity.x = -knockbackSpeed
		else:
			velocity.x = knockbackSpeed
		velocity.y = jumpImpulse / 2.0
		state = ActionState.Knockback

func set_facing_right(value: bool):
	facingRight = value
	$Sprite.flip_h = value
	$Sprite.offset.x = animOffsets[$Sprite.animation]
	$Sprite.offset.x *= -1 if facingRight else 1
	
func set_lucosa_form(value: bool):
	lucosaForm = value
	#play_anim("Idle")
	
func play_anim(anim: String):
	if lucosaForm:
		anim = "Lucosa_" + anim
		
	if !animOffsets.has(anim):
		play_anim("Idle")
	else:
		$Sprite.play(anim)
		$Sprite.offset.x = animOffsets[anim]
		$Sprite.offset.x *= -1 if facingRight else 1

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
	
func dive():
	if state != ActionState.Dive && is_air_state():
		#self.facingRight = cos(angle) < 0.0
		velocity.x = (1 if facingRight else -1) * diveVelocity
		velocity.y = knockbackSpeed if Input.is_action_pressed("ui_down") else 0.0
		state = ActionState.Dive
		
func double_jump():
	if canDoubleJump:
		velocity.y = doubleJumpImpulse
		state = ActionState.DoubleJump
		canDoubleJump = false
		
func attack():
	if canAttack:
		var child := HIT_1.instance()
		var dir := 1 if facingRight else -1
		
		child.get_node("ParticleSprite").flip_h = facingRight
		child.position.x = 12 * dir
		child.get_node("ParticleSprite").position.x = -4 * dir
		child.get_node("ParticleSprite").velocity.x = 16 * dir
		
		var attackArea := Area2D.new()
		var attackShape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.extents = Vector2(8, 6)
		attackShape.shape = rect
		attackArea.add_child(attackShape)
		attackArea.connect("body_entered", self, "land_attack")
		child.add_child(attackArea)
		
		add_child(child)
		
		canAttack = false
		$AttackTimer.start()
		
func land_attack(var target: Node2D):
	if target.has_node("EnemyData"):
		velocity.x = 0.0
		var enemyData: Enemy = target.get_node("EnemyData")
		enemyData.take_damage(attackDmg)
		
func uppercut():
	if canDoubleJump:
		velocity.y = lucosaJumpImpulse
		state = ActionState.DoubleJump
		canDoubleJump = false
		
		var child := UPPERCUT.instance()
		var dir := 1 if facingRight else -1
		
		child.get_node("ParticleSprite").flip_h = facingRight
		child.position.x = 12 * dir
		
		var attackArea := Area2D.new()
		var attackShape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.extents = Vector2(6, 8)
		attackShape.shape = rect
		attackArea.add_child(attackShape)
		attackArea.connect("body_entered", self, "land_uppercut")
		child.add_child(attackArea)
		
		add_child(child)
		
func land_uppercut(var target: Node2D):
	if target.has_node("EnemyData"):
		velocity.x = 0.0
		var enemyData: Enemy = target.get_node("EnemyData")
		enemyData.take_damage(attackDmg)
		canDoubleJump = true
		
func set_can_attack():
	canAttack = true
	#attack()
	
func on_anim_complete():
	if state == ActionState.Transforming:
		play_anim("Idle")
		state = ActionState.Normal
	
func is_air_state():
	return state == ActionState.Falling \
		|| state == ActionState.Jump \
		|| state == ActionState.DoubleJump \
		|| state == ActionState.Jab \
		|| state == ActionState.Dive \
		|| state == ActionState.Knockback
	
func is_momentum_state():
	return state == ActionState.Dive \
		|| state == ActionState.Knockback \
		|| state == ActionState.Transforming

func _ready():
	var jumpTime := jumpWidth * 4.0 / walkSpeed
	gravity = 2.0 * jumpHeight * 8.0 / (jumpTime * jumpTime)
	jumpImpulse = -gravity * jumpTime
	
	minJumpGravity = jumpImpulse * jumpImpulse / (16.0 * minJumpHeight)
	doubleJumpImpulse = -sqrt(16.0 * doubleJumpHeight * gravity)
	lucosaJumpImpulse = -sqrt(16.0 * lucosaJumpHeight * gravity)
	
	var hud := HUD.instance()
	connect("formSwap", hud, "set_icon")
	get_parent().call_deferred("add_child", hud)
	
	$AttackTimer.connect("timeout", self, "set_can_attack")
	$Sprite.connect("animation_finished", self, "on_anim_complete")
	
	self.facingRight = false
	#play_anim("Idle")
	
func _physics_process(delta: float):
	process_x_velocity(delta)
	process_y_velocity(delta)
	
	if lucosaForm:
		lucosa_abilities()
	else:
		ruirui_abilities()
		
	if Input.is_action_pressed("ui_up") && Input.is_action_just_pressed("attack"):
		play_anim("Transform")
		state = ActionState.Transforming
		velocity.x = 0.0
		self.lucosaForm = !lucosaForm
		emit_signal("formSwap", "lucosa" if self.lucosaForm else "ruirui")
		
	velocity = move_and_slide(velocity, Vector2.UP, true)
	if is_on_floor() && is_air_state():
		state = ActionState.Normal
		canDoubleJump = true
		
	if !is_on_floor() && state == ActionState.Normal:
		state = ActionState.Falling

func ruirui_abilities():
	if Input.is_action_just_pressed("attack") && !Input.is_action_pressed("ui_up"):
		dive()
	if Input.is_action_just_pressed("jump") && !is_on_floor():
		double_jump()
		
func lucosa_abilities():
	if Input.is_action_just_pressed("attack") && !Input.is_action_pressed("ui_up"):
		attack()
	if Input.is_action_just_pressed("jump") && !is_on_floor():
		uppercut()

func process_x_velocity(delta: float):
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
			play_anim("Idle")
			
func process_y_velocity(delta: float):
	var curGravity = gravity
	if jumpReleased && state == ActionState.Jump && velocity.y < 0.0:
		curGravity = minJumpGravity
	velocity.y += curGravity * delta
	if velocity.y > gravity * maxGravityMultiplier:
		velocity.y = gravity * maxGravityMultiplier

	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = jumpImpulse if !lucosaForm else lucosaJumpImpulse
		state = ActionState.Jump
		
		jumpReleased = false
	
	if Input.is_action_just_released("jump"):
		jumpReleased = true
