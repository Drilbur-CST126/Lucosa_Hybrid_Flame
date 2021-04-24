extends KinematicBody2D

const WindSword := preload("res://Enemies/Derenisa/WindSword/WindSword.tscn")

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
		States.RunDashRunning: 0.3,
		States.LongDashRunning: 0.1,
	},
	States.FirstJump: {
		States.SecondJump: 1.0,
	},
	States.SecondJump: {
		# States.RetractSwords: 1.0 (if swords are out)
		States.ShootSwords: 1.0,
	},
	States.RetractSwords: {
		States.FirstJump: 0.2,
		States.RunDashRunning: 0.4,
		States.LongDashRunning: 0.2,
		States.ShootSwords: 0.2,
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
	}
}

const kAngryAttackOdds := {
	States.FirstJump: {
		States.SecondJump: 0.2,
		States.SuperJump: 0.8,
	},
}

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
const kSuperJumpWarningTime := 1.5
onready var kStartingHp := $EnemyData.hp as int # Treated as const

export(States) var state = States.StartAnim setget set_state
export var velocity := Vector2.ZERO
export var arena := Rect2(0, 0, 320, 180)

var swords := []
var timers := []
var runningToRight := false


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
			
func is_float_state():
	return state == States.RetractSwords \
			|| state == States.ShootSwords \
			|| state == States.SuperJump \
			|| state == States.SuperJumpHover #\
			#|| state == States.SuperJumpFall

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
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
func take_damage(source):
	if (!(source is Ruicosa) || GlobalData.lucosaForm) && $StaggerCooldownTimer.time_left == 0.0:
		$StaggerCooldownTimer.start()
		self.state = States.Stagger
	
func anim_finished(_anim):
	match state:
		States.RetractSwords:
			if global_position.y > arena.position.y + arena.size.y / 2.0:
				var next := get_next_state()
				while next == States.ShootSwords && global_position.distance_to(GlobalData.player.global_position) > 64.0:
					next = get_next_state()
				self.state = next
			else:
				self.state = States.RunDashRunning
		States.ShootSwords:
			if global_position.y > arena.position.y + arena.size.y / 2.0:
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
	return true
	#return $EnemyData.hp < kStartingHp / 2.0


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
	velocity = kSecondJumpVel
	if GlobalData.player.global_position.x < global_position.x:
		velocity.x *= -1
	$AnimationPlayer.play("Jump")
	
func retract_swords():
	if swords.size() == 0:
		self.state = States.ShootSwords
		return
		
	$AnimationPlayer.play("RetractSwords")
	for sword in swords:
		sword.move_to(global_position, true)
	swords.clear()
	
func run_dash_running(delta: float):
	if is_on_floor():
		var dest := GlobalData.player.global_position
		var dir := Utility.get_dir(dest > global_position)
		velocity.x += dir * kRunAcceleration * delta
		if dir * velocity.x > kRunSpeed:
			velocity.x = dir * kRunSpeed
		if abs(dest.x - global_position.x) < 16.0:
			self.state = States.RunDash
			
func run_dash():
	var playerPos := GlobalData.player.global_position
	velocity.x = 0.0
	yield(create_timer(0.3), "timeout")
	var dir := Utility.get_dir(playerPos.x > global_position.x)
	velocity.x = dir * kDashSpeed
	yield(create_timer(kRunDashLength / kDashSpeed), "timeout")
	velocity.x = 0.0
	yield(create_timer(0.2), "timeout")
	anim_finished("RunDash")
	
func long_dash_setup():
	runningToRight = GlobalData.player.global_position.x < global_position.x
	
func long_dash_running(delta: float):
	if is_on_floor():
		var dir := Utility.get_dir(runningToRight)
		velocity.x += dir * kRunAcceleration * delta
		if dir * velocity.x > kRunSpeed:
			velocity.x = dir * kRunSpeed
		if global_position.x <= arena.position.x + 16.0 || \
				global_position.x >= arena.position.x + arena.size.x - 16.0:
			self.state = States.LongDash
			
func long_dash():
	var dir := Utility.get_dir(!runningToRight)
	yield(create_timer(0.3), "timeout")
	velocity.x = dir * kDashSpeed
	
func long_dash_await():
	var complete := (global_position.x >= arena.position.x + arena.size.x - 16.0) \
			if !runningToRight else (global_position.x <= arena.position.x + 16.0)
	if complete:
		anim_finished("LongDash")

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
		yield(create_timer(0.5), "timeout")
		self.state = States.SuperJumpHover
		
func super_jump_hover_start():
	$Particles2D.emitting = true
	yield(create_timer(kSuperJumpHoverTime), "timeout")
	self.state = States.SuperJumpWarning
	
func super_jump_hover():
	global_position.x = GlobalData.player.global_position.x

func super_jump_warning():
	$Particles2D.emitting = false
	yield(create_timer(kSuperJumpWarningTime), "timeout")
	self.state = States.SuperJumpFall
