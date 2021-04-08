extends KinematicBody2D
class_name Ruicosa

const HUD = preload("res://Code/HUD.tscn")
const RuiruiHealthScene = preload("res://Code/HealMinigame/RuiruiHealthScene.tscn")
const LucosaHealthScene = preload("res://Code/HealMinigame/LucosaHealthScene.tscn")
const Enemy = preload("res://Code/Enemy.gd")
const Fireball = preload("res://Ruicosa/Fireball/Fireball.tscn")
const PauseMenu = preload("res://Menu/PauseMenu.tscn")

const kHit1Particle = preload("res://Graphics/Particles/Hit1/Hit1.tscn")
const kUppercutParticle = preload("res://Graphics/Particles/Uppercut/Uppercut.tscn")


enum ActionState {
	Normal,
	Falling,
	Jump,
	FullJump,
	DoubleJump,
	Jab,
	Dive,
	Knockback,
	Transforming,
	Attacking,
	Healing,
	MinecartEnter,
	InMinecart,
	Stun,
}


const animOffsets := {
	"Idle": -10,
	"Run": 20,
	"Transform": -20,
	"Lucosa_Transform": -20,
	"Lucosa_Idle": -20,
	"Lucosa_Uppercut": -20,
	"Lucosa_Run": -20,
	"Lucosa_Attack": -20,
}

const walkSpeed := 128.0
const runSpeed := 180.0
const maxSpeedTime := 0.15
const maxGravityMultiplier := 4.0
const knockbackSpeed := 64.0

const jumpHeight := 6.0
const minJumpHeight := 2.5
const doubleJumpHeight := 3.5
const lucosaJumpHeight := 4.0
const jumpWidth := 11.0
const maxCoyoteTime := 0.1
const jumpTime := jumpWidth * 4.0 / walkSpeed
const gravity = 2.0 * jumpHeight * 8.0 / (jumpTime * jumpTime)
const jumpImpulse := -gravity * jumpTime

const diveVelocity := 256.0
const kFireballForce := Vector2(192.0, -128.0)

export var detectCollision := false
export var facingRight := true setget set_facing_right

var doubleJumpImpulse: float
var lucosaJumpImpulse: float
var minJumpGravity: float
onready var hud := HUD.instance()

var jumpReleased := false
var canDoubleJump: bool
var coyoteTime := 0.0
onready var respawnPos := position

var running := false

export var lucosaForm := false setget set_lucosa_form
var vulnerable := true
var canAttack := true

var velocity := Vector2()
var state = ActionState.Normal


signal formSwap(form)
signal dive(Node2D)


func get_class():
	return "Ruicosa"
	
func look_at(pos: Vector2):
	self.facingRight = pos.x > position.x
	
func knockback(enemy: Enemy, damage := 0):
	play_anim("Idle", true)
	if (state == ActionState.Dive || $DiveExtraTimer.time_left > 0.0) && enemy != null:
		if facingRight:
			velocity.x = -walkSpeed
		else:
			velocity.x = walkSpeed
		velocity.y = jumpImpulse
		state = ActionState.Normal
		canDoubleJump = form_has_double_jump()
		if enemy.vulnerable:
			enemy.take_damage(get_attack_damage(!enemy.blocking), self)
	elif vulnerable:
		if (damage > 0):
			GlobalData.playerHp -= damage
		
		if facingRight:
			velocity.x = -knockbackSpeed
		else:
			velocity.x = knockbackSpeed
		velocity.y = jumpImpulse / 2.0
		state = ActionState.Knockback
		
func take_damage(amt: int):
	if vulnerable:
		GlobalData.playerHp -= amt

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
	
func get_attack_damage(consumeCharges := true) -> int:
	if GlobalData.chargeEnabled && consumeCharges && GlobalData.charges > 0:
		GlobalData.charges -= 1
		return 2 * GlobalData.playerAttackDmg
	else:
		return GlobalData.playerAttackDmg
	
func play_anim(anim: String, force := false, reset := false):
	if force || !is_anim_freeze_state():
		if lucosaForm:
			anim = "Lucosa_" + anim
			
		if !animOffsets.has(anim):
			play_anim("Idle")
		else:
			if reset && $Sprite.animation == anim:
				$Sprite.frame = 0
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
		$SoundManager.play_sound("Dive")
		jumpReleased = true
		#self.facingRight = cos(angle) < 0.0
		velocity.x = (1 if facingRight else -1) * diveVelocity
		velocity.y = knockbackSpeed if Input.is_action_pressed("ui_down") else 0.0
		state = ActionState.Dive
		emit_signal("dive", self)
		
func double_jump():
	if canDoubleJump:
		$SoundManager.play_sound("DoubleJump")
		velocity.y = doubleJumpImpulse
		state = ActionState.DoubleJump
		canDoubleJump = false
		
func attack():
	if canAttack && !is_anim_freeze_state():
		$SoundManager.play_sound("Attack")
		play_anim("Attack")
		var child := kHit1Particle.instance()
		var dir := 1 if facingRight else -1
		
		#child.get_node("ParticleSprite").flip_h = facingRight
		child.position.x = 12 * dir
		#child.get_node("ParticleSprite").position.x = -4 * dir
		#child.get_node("ParticleSprite").velocity.x = 16 * dir
		
		var attackArea := Area2D.new()
		attackArea.collision_layer = 0b101
		var attackShape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.extents = Vector2(6, 6)
		attackShape.shape = rect
		attackArea.add_child(attackShape)
		Utility.print_connect_errors(get_path(), [
			attackArea.connect("body_entered", self, "land_attack", [attackArea]),
			attackArea.connect("area_entered", self, "land_attack", [attackArea]),
		])
		child.add_child(attackArea)
		
		add_child(child)
		
		#GlobalData.playerMana -= 20
		canAttack = false
		state = ActionState.Attacking
		$AttackTimer.start()
		
func land_attack(var target: Node2D, var attackArea: Area2D):
	if target.get_class() == "Fireball":
		var impulse := kFireballForce
		impulse.x *= 1 if facingRight else -1
		(target as RigidBody2D).linear_velocity += impulse
	if target.has_node("EnemyData"):
		velocity.x = 0.0
		var enemyData: Enemy = target.get_node("EnemyData")
		if enemyData.vulnerable:
			enemyData.take_damage(get_attack_damage(!enemyData.blocking), self)
		attackArea.queue_free()
		
func uppercut():
	if canDoubleJump && (!is_anim_freeze_state() || state == ActionState.DoubleJump):
		$SoundManager.play_sound("Uppercut")
		play_anim("Uppercut", true, true)
		velocity.y = lucosaJumpImpulse
		state = ActionState.DoubleJump
		canDoubleJump = false
		
		var child := kUppercutParticle.instance() as Node2D
		var dir := 1 if facingRight else -1
		
		child.get_node("ParticleSprite").flip_h = facingRight
		child.position.x = 12 * dir
		child.hide()
		
		var attackArea := Area2D.new()
		var attackShape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.extents = Vector2(6, 8)
		attackShape.shape = rect
		attackArea.add_child(attackShape)
		Utility.print_connect_errors(get_path(), [
			attackArea.connect("body_entered", self, "land_uppercut"),
			attackArea.connect("area_entered", self, "land_uppercut"),
		])
		child.add_child(attackArea)
		
		add_child(child)
		
func land_uppercut(var target: Node2D):
	if target.has_node("EnemyData"):
		velocity.x = 0.0
		var enemyData: Enemy = target.get_node("EnemyData")
		if enemyData.vulnerable:
			enemyData.take_damage(get_attack_damage(!enemyData.blocking), self)
		canDoubleJump = true
		
func fireball():
	var canCast := true
	for child in get_parent().get_children():
		if child.get_class() == "Fireball":
			canCast = false
			
	if canCast:
		var child := Fireball.instance()
		var dir := 1 if facingRight else -1
		var vel := velocity
		vel.y += kFireballForce.y
		
		child.gravity_scale = gravity / 9.8 / 9.8
		child.linear_velocity = vel
		child.global_position = global_position
		child.position.x += 12 * dir
		
		get_parent().add_child_below_node(self, child)
		
func begin_heal():
	if is_on_floor() && !GlobalData.player_at_full_hp() \
			&& state != ActionState.Healing && GlobalData.playerMana == GlobalData.kMaxMana:
		state = ActionState.Healing
		GlobalData.playerMana = 0.0
		GlobalData.regenMana = false
		var healScene := LucosaHealthScene.instance() if lucosaForm else RuiruiHealthScene.instance()
		hud.add_child(healScene)
		Utility.print_connect_errors(get_path(), [
			healScene.connect("on_finish", self, "end_heal"),
			GlobalData.connect("player_hit", self, "interrupt_heal", [healScene])
		])
		GlobalData.distributeHpShards = false

func end_heal():
	state = ActionState.Normal
	GlobalData.regenMana = true
	GlobalData.disconnect("player_hit", self, "interrupt_heal")
	GlobalData.distributeHpShards = true
		
func interrupt_heal(_hp: int, healScene):
	healScene.queue_free()
	end_heal()
		
func set_can_attack():
	canAttack = true
	#attack()
	
func jump(full := false):
	$SoundManager.play_sound("Jump")
	velocity.y = jumpImpulse if !lucosaForm else lucosaJumpImpulse
	state = ActionState.Jump if !full else ActionState.FullJump
	
	jumpReleased = false
	coyoteTime = 0.0
	
func on_anim_complete():
	if state == ActionState.Transforming:
		play_anim("Idle")
		state = ActionState.Normal
	elif state == ActionState.Attacking:
		play_anim("Idle")
		state = ActionState.Normal
	elif state == ActionState.DoubleJump:
		play_anim("Idle", true)
		state = ActionState.Normal
	
func is_air_state() -> bool:
	return state == ActionState.Falling \
		|| state == ActionState.Jump \
		|| state == ActionState.DoubleJump \
		|| state == ActionState.Jab \
		|| state == ActionState.Dive \
		|| state == ActionState.Knockback
	
func is_momentum_state() -> bool:
	return state == ActionState.Dive \
		|| state == ActionState.Knockback \
		|| state == ActionState.Transforming \
		|| state == ActionState.MinecartEnter
		
func is_stun_state() -> bool:
	return state == ActionState.Healing \
		|| state == ActionState.InMinecart \
		|| state == ActionState.Stun
		
func is_anim_freeze_state():
	return state == ActionState.Attacking \
		|| state == ActionState.DoubleJump

func on_damaged(_amt):
	vulnerable = false
	$Sprite.modulate.a = 0.6
	$HitTimer.start()
	yield($HitTimer, "timeout")
	vulnerable = true
	$Sprite.modulate.a = 1
	
func on_collide(obj: Node2D):
	if obj.is_in_group("DamageObject") && vulnerable:
		take_damage(1)
		if GlobalData.playerHp > 0:
			yield(GlobalData, "hit_animation_finished")
			position = respawnPos
			velocity = Vector2.ZERO
			if GlobalData.camera != null:
				GlobalData.camera.global_position = global_position
	if obj.is_in_group("StablePlatform") && is_on_floor() \
			&& $LeftGroundRayCast.get_collider() == obj \
			&& $RightGroundRayCast.get_collider() == obj:
		respawnPos = position
	
func form_has_double_jump() -> bool:
	return GlobalData.hasUppercut if lucosaForm \
			else GlobalData.hasDoubleJump

func _ready():
	GlobalData.gravity = gravity
	GlobalData.player = self
	
	minJumpGravity = jumpImpulse * jumpImpulse / (16.0 * minJumpHeight)
	doubleJumpImpulse = -sqrt(16.0 * doubleJumpHeight * gravity)
	lucosaJumpImpulse = -sqrt(16.0 * lucosaJumpHeight * gravity)
	
	get_parent().call_deferred("add_child", hud)
	
	Utility.print_connect_errors(get_path(),[
		connect("formSwap", hud, "set_icon"),
		$AttackTimer.connect("timeout", self, "set_can_attack"),
		$Sprite.connect("animation_finished", self, "on_anim_complete"),
		GlobalData.connect("player_hit", self, "on_damaged"),
	])
	
	set_facing_right(facingRight)
	self.lucosaForm = GlobalData.lucosaForm
	hud.set_icon("lucosa" if self.lucosaForm else "ruirui")
	#hud.get_node("Control").add_child(PauseMenu.instance())
	canDoubleJump = form_has_double_jump()
	#play_anim("Idle")
	
	$LeftGroundRayCast.enabled = detectCollision
	$RightGroundRayCast.enabled = detectCollision
	
func _process(_delta: float):
	if Input.is_action_just_pressed("spell"):
		GlobalData.chargeEnabled = !GlobalData.chargeEnabled
		
	if Input.is_action_just_pressed("menu"):
		hud.control.add_child(PauseMenu.instance())
	
func _physics_process(delta: float):
	if !is_stun_state():
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
			if state == ActionState.Dive:
				$DiveExtraTimer.start()
			state = ActionState.Normal
			canDoubleJump = form_has_double_jump()
			
		if !is_on_floor() && state == ActionState.Normal:
			state = ActionState.Falling
			
		if detectCollision:
			for i in range(0, get_slide_count()):
				var collision := get_slide_collision(i)
				on_collide(collision.collider)

func ruirui_abilities():
	if Input.is_action_just_pressed("second_attack") && !Input.is_action_pressed("ui_up"):
		dive()
	if Input.is_action_just_pressed("jump") && coyoteTime < 0.0:
		double_jump()
		
func lucosa_abilities():
	if Input.is_action_just_pressed("attack") && !Input.is_action_pressed("ui_up"):
		attack()
	if Input.is_action_just_pressed("jump") && coyoteTime < 0.0:
		uppercut()
	if Input.is_action_just_pressed("second_attack") && GlobalData.hasFireball:
		fireball()

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
		jump()
	
	if Input.is_action_just_released("jump"):
		jumpReleased = true
