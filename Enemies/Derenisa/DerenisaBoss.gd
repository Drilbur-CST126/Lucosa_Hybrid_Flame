extends KinematicBody2D

const WindSword := preload("res://Enemies/Derenisa/WindSword/WindSword.tscn")

enum States { StartAnim = 0, ShootSwords = 1, FirstJump = 2, SecondJump = 3, RetractSwords = 4 }

const kAttackOdds := {
	States.StartAnim: {
		States.ShootSwords: 0.5,
		States.FirstJump: 0.5,
	},
	States.ShootSwords: {
		States.FirstJump: 1.0,
	},
	States.FirstJump: {
		States.SecondJump: 1.0,
	},
	States.SecondJump: {
		States.ShootSwords: 1.0,
	},
	States.RetractSwords: {
		States.FirstJump: 1.0
	}
}

const kSpreadAngle := deg2rad(30.0)
const kWindSwordDist := 7.0 * 8.0
const kFirstJumpVel := Vector2(0.0, -256.0)
const kSecondJumpVel := Vector2(128.0, -256.0)

export(States) var state = States.StartAnim setget set_state
export var velocity := Vector2.ZERO

var swords := []

	
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
			
func is_float_state():
	return state == States.RetractSwords \
			|| state == States.ShootSwords

func _ready():
	Utility.print_errors([
		$AnimationPlayer.connect("animation_finished", self, "anim_finished")
	])
	
func _process(delta):
	if !is_float_state():
		velocity.y += GlobalData.gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
func anim_finished(_anim):
	match state:
		States.SecondJump:
			if swords.size() > 0:
				self.state = States.RetractSwords
			else:
				next_state()
		_:
			next_state()
	
func next_state():
	self.state = Utility.select_option(kAttackOdds[state])
	
func shoot_swords():
	$AnimationPlayer.play("ShootSwords")
	
	var baseAngle := global_position.angle_to_point(GlobalData.player.global_position) + PI
	if is_on_floor():
		if baseAngle < 1.5 * PI: 
			baseAngle = PI + kSpreadAngle
		else:
			baseAngle = PI - kSpreadAngle
	
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
	$AnimationPlayer.play("RetractSwords")
	for sword in swords:
		sword.move_to(global_position)
	yield($AnimationPlayer, "animation_finished")
	for sword in swords:
		sword.queue_free()
	swords.clear()
