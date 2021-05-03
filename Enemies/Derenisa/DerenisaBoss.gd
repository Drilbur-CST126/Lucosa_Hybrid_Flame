extends KinematicBody2D

const WindSword := preload("res://Enemies/Derenisa/WindSword/WindSword.tscn")
const WindWall := preload("res://Enemies/Derenisa/WindWall/WindWall.tscn")

enum States { 
		StartAnim = 0, 
		ShootSwords = 1, 
		FirstJump = 2, 
		SecondJump = 3, 
		RetractSwords = 4,
		RunDashRunning = 5,
		RunDash = 6,
		Stagger = 7,
		LongDashRunning = 8,
		LongDash = 9,
		SuperJump = 10,
		SuperJumpHover = 11,
		SuperJumpWarning = 12,
		SuperJumpFall = 13,
	}

const kAttackOdds := {
	States.StartAnim: {
		States.ShootSwords: 0.5,
		States.FirstJump: 0.2,
		States.RunDashRunning: 0.3,
	},
	States.ShootSwords: {
		States.FirstJump: 0.6,
		States.RunDashRunning: 0.4,
	},
	States.FirstJump: {
		States.SecondJump: 1.0,
	},
	States.SecondJump: {
		# States.RetractSwords: 1.0 (if swords are out)
		States.ShootSwords: 1.0,
	},
	States.RetractSwords: {
		States.FirstJump: 0.3,
		States.RunDashRunning: 0.3,
		States.LongDashRunning: 0.1,
		States.ShootSwords: 0.3,
	},
	States.RunDashRunning: {
		States.ShootSwords: 0.6,
		States.FirstJump: 0.4,
	},
	States.RunDash: {
		States.ShootSwords: 1.0,
	},
	States.Stagger: {
		States.RunDash: 0.5,
		States.ShootSwords: 0.15,
		States.FirstJump: 0.15,
		States.LongDashRunning: 0.2,
	},
	States.LongDash: {
		States.FirstJump: 0.5,
		States.ShootSwords: 0.5,
	},
	States.SuperJumpFall: {
		States.ShootSwords: 0.5,
		States.FirstJump: 0.2,
		States.RunDashRunning: 0.3,
	},
}

const kAngryAttackOdds := {
	States.FirstJump: {
		States.SecondJump: 0.8,
		States.SuperJump: 0.2,
	},
	States.ShootSwords: {
		States.FirstJump: 0.5,
		States.RunDashRunning: 0.3,
		States.LongDashRunning: 0.2,
	},
	States.RetractSwords: {
		States.FirstJump: 0.2,
		States.RunDashRunning: 0.4,
		States.LongDashRunning: 0.3,
		States.ShootSwords: 0.1,
	},
}

const kAnimEndTransitionStates := [
	States.StartAnim,
	States.ShootSwords,
	States.RetractSwords,
	States.FirstJump,
	States.SecondJump,
	States.Stagger,
	States.RunDash,
]

const kSpreadAngle := deg2rad(30.0)
const kWindSwordDist := 5.0 * 8.0
const kFirstJumpVel := Vector2(0.0, -256.0)
const kSecondJumpVel := Vector2(256.0, -256.0)
const kRunAcceleration := 512.0
const kRunSpeed := 192.0
const kDashSpeed := 256.0
const kLongDashSpeed := 384.0
const kRunDashLength := 64.0
const kSuperJumpVelocity := 384.0
const kSuperJumpHoverTime := 2.5
const kSuperJumpWarningTime := 1.0
onready var kStartingHp := $EnemyData.hp as int # Treated as const

export(States) var state = States.StartAnim setget set_state
export var velocity := Vector2.ZERO
export var arena := Rect2(0, 0, 320, 180)

var swords := []
var timers := []
var facingRight := false setget set_facing_right
var onGround := false

signal hit_ground()

func start():
	$AnimationPlayer.play("Start")

func set_state(val):
	state = val
	$Label.text = String(val)
	match state:
		States.ShootSwords:
			shoot_swords()
		States.FirstJump:
			first_jump()
		States.SecondJump:
			second_jump()
		States.RetractSwords:
			retract_swords()
		States.RunDashRunning:
			run_dash_setup()
		States.RunDash:
			run_dash()
		States.Stagger:
			stagger()
		States.LongDashRunning:
			long_dash_setup()
		States.LongDash:
			long_dash()
		States.SuperJump:
			super_jump()
		States.SuperJumpHover:
			super_jump_hover_start()
		States.SuperJumpWarning:
			super_jump_warning()
		States.SuperJumpFall:
			super_jump_fall()
			
func set_facing_right(val: bool):
	facingRight = val
	var dir := Utility.get_dir(!val)
	$Sprite.scale.x = dir / 6.0
			
func is_float_state():
	return state == States.RetractSwords \
			|| state == States.ShootSwords \
			|| state == States.SuperJump \
			|| state == States.SuperJumpHover \
			|| state == States.SuperJumpWarning

func _ready():
	Utility.print_errors([
		$AnimationPlayer.connect("animation_finished", self, "anim_finished"),
		$EnemyData.connect("on_hit", self, "take_damage"),
	])
	
func _process(delta):
	if !is_float_state():
		velocity.y += GlobalData.gravity * delta
		
	match state:
		States.RunDashRunning:
			run_dash_running(delta)
		States.LongDashRunning:
			long_dash_running(delta)
		States.LongDash:
			long_dash_await()
		States.SuperJump:
			super_jump_await()
		States.SuperJumpHover:
			super_jump_hover()
			
	if !onGround && is_on_floor():
		emit_signal("hit_ground")
	onGround = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func _exit_tree():
	for sword in swords:
		sword.queue_free()
	
	
func take_damage(source):
	if (!(source is Ruicosa) || GlobalData.lucosaForm) && $StaggerCooldownTimer.time_left == 0.0:
		$StaggerCooldownTimer.start()
		self.state = States.Stagger
	
func anim_finished(_anim):
	if Utility.contains(kAnimEndTransitionStates, state):
		match state:
			States.RetractSwords:
				if global_position.y > arena.position.y + arena.size.y / 3.0:
					var next := get_next_state()
					while next == States.ShootSwords && global_position.distance_to(GlobalData.player.global_position) > 64.0:
						next = get_next_state()
					self.state = next
				else:
					self.state = States.RunDashRunning
			States.ShootSwords:
				if global_position.y > arena.position.y + arena.size.y / 3.0:
					var next := get_next_state()
					while next == States.ShootSwords && global_position.distance_to(GlobalData.player.global_position) > 64.0:
						next = get_next_state()
					self.state = next
				else:
					self.state = States.RunDashRunning
			_:
				next_state()
	
func next_state():
	self.state = get_next_state()
	
func get_next_state() -> int:
	if is_angry() && kAngryAttackOdds.has(state):
		return Utility.select_option(kAngryAttackOdds[state])
	return Utility.select_option(kAttackOdds[state])
	
func create_timer(time: float) -> Timer:
	var timer := Timer.new()
	timer.wait_time = time
	timer.one_shot = true
	add_child(timer)
	Utility.print_errors([
		timer.connect("timeout", self, "free_timer", [timer]),
	])
	timers.append(timer)
	timer.start()
	return timer
	
func free_timer(timer: Timer):
	timers.erase(timer)
	timer.queue_free()
	
func clear_timers():
	for timer in timers:
		if timer != null:
			timer.queue_free()
	timers.clear()
	
func is_angry() -> bool:
	#return true
	return $EnemyData.hp < kStartingHp / 2.0


func shoot_swords():
	if swords.size() > 0:
		self.state = States.RetractSwords
		return
	
	$AnimationPlayer.play("ShootSwords")
	yield(create_timer(0.3), "timeout")
	
	var baseAngle := global_position.angle_to_point(GlobalData.player.global_position) + PI
	if is_on_floor():
		if baseAngle < 1.5 * PI: 
			baseAngle = PI + kSpreadAngle
		else:
			baseAngle = 2 * PI - kSpreadAngle
	
	for angle in [baseAngle, baseAngle - kSpreadAngle, baseAngle + kSpreadAngle]:
		var sword := WindSword.instance() as PlayerArea
		get_parent().add_child(sword)
		sword.global_position = global_position
		sword.move_relative(kWindSwordDist * Vector2(cos(angle), sin(angle)))
		swords.append(sword)
		
func first_jump():
	velocity = kFirstJumpVel
	$AnimationPlayer.play("Jump")
		
func second_jump():
	self.facingRight = GlobalData.player.global_position.x > global_position.x
	velocity = kSecondJumpVel
	if !facingRight:
		velocity.x *= -1
	$AnimationPlayer.play("Jump")
	
func retract_swords():
	if swords.size() == 0:
		self.state = States.ShootSwords
		return
		
	$AnimationPlayer.play("RetractSwords")
	self.facingRight = swords[0].global_position.x > global_position.x
	for sword in swords:
		sword.move_to(global_position, true)
	swords.clear()
	
func run_dash_setup():
	$AnimationPlayer.play("Run")
	self.facingRight = GlobalData.player.global_position.x > global_position.x
	
func run_dash_running(delta: float):
	if is_on_floor():
		var dest := GlobalData.player.global_position
		self.facingRight = dest > global_position
		var dir := Utility.get_dir(facingRight)
		velocity.x += dir * kRunAcceleration * delta
		if dir * velocity.x > kRunSpeed:
			velocity.x = dir * kRunSpeed
		if abs(dest.x - global_position.x) < 16.0:
			self.state = States.RunDash
			
func run_dash():
	#var playerPos := GlobalData.player.global_position
	velocity.x = 0.0
	$AnimationPlayer.play("Run")
	yield(create_timer(0.3), "timeout")
	$AnimationPlayer.play("Dash")
	var dir := Utility.get_dir(facingRight)
	velocity.x = dir * kDashSpeed
	yield(create_timer(kRunDashLength / kDashSpeed), "timeout")
	velocity.x = 0.0
	yield(create_timer(0.2), "timeout")
	anim_finished("RunDash")
	
func long_dash_setup():
	$AnimationPlayer.play("Run")
	self.facingRight = GlobalData.player.global_position.x < global_position.x
	
func long_dash_running(delta: float):
	if is_on_floor():
		var dir := Utility.get_dir(facingRight)
		velocity.x += dir * kRunAcceleration * delta
		if dir * velocity.x > kRunSpeed:
			velocity.x = dir * kRunSpeed
		if global_position.x <= arena.position.x + 16.0 || \
				global_position.x >= arena.position.x + arena.size.x - 16.0:
			self.state = States.LongDash
			
func long_dash():
	self.facingRight = !facingRight
	var dir := Utility.get_dir(facingRight)
	yield(create_timer(0.3), "timeout")
	$AnimationPlayer.play("Dash")
	velocity.x = dir * kDashSpeed
	
func long_dash_await():
	var complete := (global_position.x >= arena.position.x + arena.size.x - 16.0) \
			if facingRight else (global_position.x <= arena.position.x + 16.0)
	if complete:
		next_state()

func stagger():
	$AnimationPlayer.play("Stagger")
	clear_timers()
	velocity = Vector2.ZERO
	
func super_jump():
	velocity.y = -kSuperJumpVelocity
	
func super_jump_await():
	var goalPos := arena.position.y - ($CollisionShape2D.shape as RectangleShape2D).extents.y
	if global_position.y <= goalPos:
		global_position.y = goalPos
		velocity.y = 0.0
		#yield(create_timer(0.5), "timeout")
		self.state = States.SuperJumpHover
		
func super_jump_hover_start():
	$Particles2D.emitting = true
	yield(create_timer(kSuperJumpHoverTime), "timeout")
	self.state = States.SuperJumpWarning
	
func super_jump_hover():
	global_position.x = GlobalData.player.global_position.x

func super_jump_warning():
	yield(create_timer(kSuperJumpWarningTime), "timeout")
	$Particles2D.emitting = false
	self.state = States.SuperJumpFall
	
func super_jump_fall():
	velocity.y = 128.0
	$AnimationPlayer.play("SuperJumpFall")
	
	yield(self, "hit_ground")
	$AnimationPlayer.play("SuperJumpFreeze")
	
	var leftWall := WindWall.instance() as PlayerArea
	var rightWall := leftWall.duplicate()
	rightWall.movingRight = true
	get_parent().add_child_below_node(self, leftWall)
	get_parent().add_child_below_node(self, rightWall)
	leftWall.global_position = global_position
	rightWall.global_position = global_position
	
	yield(create_timer(1.25), "timeout")
	next_state()
