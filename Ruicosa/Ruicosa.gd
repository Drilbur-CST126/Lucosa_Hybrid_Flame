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
	Transforming,
	Attacking,
}


const animOffsets := {
	"Idle": -10,
	"Run": 20,
	"Transform": -20,
	"Lucosa_Transform": -20,
	"Lucosa_Idle": -20,
	"Lucosa_Run": -20,
	"Lucosa_Attack": -20,
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
const jumpWidth := 11.0
const maxCoyoteTime := 0.1

const diveVelocity := 256.0

var jumpImpulse: float
var doubleJumpImpulse: float
var lucosaJumpImpulse: float
var gravity: float
var minJumpGravity: float
var jumpReleased := false
var canDoubleJump: bool
var coyoteTime := 0.0
var facingRight := true setget set_facing_right

var running := false

var lucosaForm := false setget set_lucosa_form
var vulnerable := true
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
		canDoubleJump = form_has_double_jump()
	elif vulnerable:
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
	GlobalData.lucosaForm = value
	canDoubleJump = form_has_double_jump()
	#play_anim("Idle")
	
func play_anim(anim: String, force := false):
	if force || !is_anim_freeze_state():
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
	if GlobalData.hasDive && state != ActionState.Dive \
			&& is_air_state():
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
		play_anim("Attack")
		var child := HIT_1.instance()
		var dir := 1 if facingRight else -1
		
		#child.get_node("ParticleSprite").flip_h = facingRight
		child.position.x = 12 * dir
		#child.get_node("ParticleSprite").position.x = -4 * dir
		#child.get_node("ParticleSprite").velocity.x = 16 * dir
		
		var attackArea := Area2D.new()
		var attackShape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.extents = Vector2(6, 6)
		attackShape.shape = rect
		attackArea.add_child(attackShape)
		attackArea.connect("body_entered", self, "land_attack", [attackArea])
		child.add_child(attackArea)
		
		add_child(child)
		
		#GlobalData.playerMana -= 20
		canAttack = false
		state = ActionState.Attacking
		$AttackTimer.start()
		
func land_attack(var target: Node2D, var attackArea: Area2D):
	if target.has_node("EnemyData"):
		velocity.x = 0.0
		var enemyData: Enemy = target.get_node("EnemyData")
		enemyData.take_damage(attackDmg)
		attackArea.queue_free()
		
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
	elif state == ActionState.Attacking:
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

func on_damaged(_amt):
	vulnerable = false
	$Sprite.modulate.a = 0.6
	$HitTimer.start()
	yield($HitTimer, "timeout")
	vulnerable = true
	$Sprite.modulate.a = 1
		
func is_anim_freeze_state():
	return state == ActionState.Attacking
	
func form_has_double_jump() -> bool:
	return GlobalData.hasUppercut if lucosaForm \
			else GlobalData.hasDoubleJump

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
	GlobalData.connect("player_hit", self, "on_damaged")
	
	self.facingRight = false
	self.lucosaForm = GlobalData.lucosaForm
	hud.set_icon("lucosa" if self.lucosaForm else "ruirui")
	canDoubleJump = form_has_double_jump()
	#play_anim("Idle")
	
func _physics_process(delta: float):
	process_x_velocity(delta)
	process_y_velocity(delta)
	
	if lucosaForm:
		lucosa_abilities()
	else:
		ruirui_abilities()
		
	if ((Input.is_action_pressed("ui_up") && Input.is_action_just_pressed("attack")) \
			|| Input.is_action_just_pressed("transform")) && is_on_floor() \
			&& GlobalData.canTransform:
		play_anim("Transform")
		state = ActionState.Transforming
		velocity.x = 0.0
		self.lucosaForm = !lucosaForm
		emit_signal("formSwap", "lucosa" if self.lucosaForm else "ruirui")
		
	velocity = move_and_slide(velocity, Vector2.UP, true)
	if is_on_floor() && is_air_state():
		state = ActionState.Normal
		canDoubleJump = form_has_double_jump()
		
	if !is_on_floor() && state == ActionState.Normal:
		state = ActionState.Falling

func ruirui_abilities():
	if Input.is_action_just_pressed("attack") && !Input.is_action_pressed("ui_up"):
		dive()
	if Input.is_action_just_pressed("jump") && coyoteTime < 0.0:
		double_jump()
		
func lucosa_abilities():
	if Input.is_action_just_pressed("attack") && !Input.is_action_pressed("ui_up"):
		attack()
	if Input.is_action_just_pressed("jump") && coyoteTime < 0.0:
		uppercut()

func process_x_velocity(delta: float):
	if !is_momentum_state():
		var curSpeed = runSpeed if running else walkSpeed
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
		
	if is_on_floor():
		coyoteTime = maxCoyoteTime
		if Input.is_action_pressed("attack") && lucosaForm == false:
			running = true
		else:
			running = false
	else:
		#print(coyoteTime)
		coyoteTime -= delta

	if Input.is_action_just_pressed("jump") && coyoteTime > 0.0:
		velocity.y = jumpImpulse if !lucosaForm else lucosaJumpImpulse
		state = ActionState.Jump
		
		jumpReleased = false
		coyoteTime = 0.0
	
	if Input.is_action_just_released("jump"):
		jumpReleased = true
