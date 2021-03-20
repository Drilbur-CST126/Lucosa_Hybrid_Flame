extends KinematicBody2D

const Spear := preload("res://Enemies/EarthLucosa/Spear/Spear.tscn")

const kWalkVelocity := 64.0
const kWallCastLength := 13.0

enum States {
	Moving, Standing, SpearAttack, JumpAttack, HitStun
}

export var facingRight := true setget set_facing_right

var state = States.Moving
var velocity := Vector2.ZERO
var curOnWall := false

func set_facing_right(val: bool):
	facingRight = val
	var dir := Utility.get_dir(facingRight)
	$WallRayCast.cast_to.x = dir * kWallCastLength
	$SignalArea.scale.x = dir

func _ready():
	Utility.print_errors([
		$StandTimer.connect("timeout", self, "turn_around"),
		$SignalArea.connect("has_player", self, "see_player"),
		$AnimationPlayer.connect("animation_finished", self, "anim_finished"),
		$EnemyData.connect("on_hit", self, "on_hit"),
	])

func _physics_process(_delta):
	match state:
		States.Moving:
			velocity = Vector2(Utility.get_dir(facingRight) * kWalkVelocity, 0.0)
			
			if $WallRayCast.is_colliding() || (is_on_wall() && !curOnWall):
				start_turn_around()
	
	curOnWall = is_on_wall()
	
	velocity = move_and_slide(velocity, Vector2.UP)


func is_attacking_state() -> bool:
	return state == States.SpearAttack || state == States.JumpAttack

func start_turn_around():
	$StandTimer.start()
	state = States.Standing
	velocity = Vector2.ZERO

func turn_around():
	self.facingRight = !facingRight
	state = States.Moving
	
func decide_attack(player: Ruicosa):
	if abs(player.global_position.y - global_position.y) < 5.0 || !player.is_on_floor():
		return States.SpearAttack
	else:
		return States.JumpAttack
	
func see_player():
	if $AttackCooldownTimer.time_left > 0.0:
		yield($AttackCooldownTimer, "timeout")
	var player := $SignalArea.player as Ruicosa
	if player != null:
		match decide_attack(player):
			States.SpearAttack:
				state = States.SpearAttack
				velocity = Vector2.ZERO
				var angle := global_position.angle_to_point(player.global_position) + PI
				$Graphics/AttackIndicator.rotation = angle
				$AnimationPlayer.play("SpearAttackWindup")
				$AttackCooldownTimer.start()
			States.JumpAttack:
				print("Jump Attack")

func anim_finished(anim: String):
	match anim:
		"SpearAttackWindup":
			var spear := Spear.instance() as Area2D
			spear.rotation = $Graphics/AttackIndicator.rotation
			add_child(spear)
			$AnimationPlayer.play("SpearAttack")
		"SpearAttack":
			state = States.Moving
			
func on_hit(_src):
	if !is_attacking_state():
		state = States.HitStun
		velocity = Vector2.ZERO
		yield(Utility.create_timer(self, 0.2), "timeout")
		if !is_attacking_state():
			state = States.Moving
