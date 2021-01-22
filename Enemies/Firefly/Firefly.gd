extends KinematicBody2D

const kWanderRange := 24.0
const kMoveSpeed := 48.0
const kChaseHeightAbovePlayer := 24.0
const kChaseLineWidth := 32.0
const kAnimationRotation := 3.0

enum State {
	Wander,
	Chase,
}

onready var kInitialPosition = global_position

var dest: Vector2
var player: Ruicosa = null
var state = State.Wander

func wander():
	if state == State.Wander:
		var dist := kWanderRange * sqrt(GlobalData.random.randf())
		var angle := 2 * PI * GlobalData.random.randf()
		dest = kInitialPosition + Vector2(dist * cos(angle), dist * sin(angle))
		$WanderTimer.start()
	
func check_if_player_entered(other: Node2D):
	if other is Ruicosa:
		state = State.Chase
		player = other
		dest = player.global_position
		
func closest_chase_dest() -> Vector2:
	var a := player.global_position - Vector2(kChaseLineWidth, kChaseHeightAbovePlayer)
	var b := player.global_position - Vector2(-kChaseLineWidth, kChaseHeightAbovePlayer)
	var p := global_position
	
	var v := b - a
	var u := a - p
	var vu := v.dot(u)
	var vv := v.dot(v)
	
	var t := -vu / vv
	if t >= 0 && t <= 1:
		return vector_to_segment(t, Vector2.ZERO, a, b)
		
	var g0 := vector_to_segment(0, p, a, b).length_squared()
	var g1 := vector_to_segment(1, p, a, b).length_squared()
	
	return a if g0 <= g1 else b
	
func vector_to_segment(t: float, p: Vector2, a: Vector2, b: Vector2) -> Vector2:
	return (1 - t) * a + t * b - p
	
func _ready():
	wander()
	Utility.print_connect_errors(get_path(), [
		$WanderTimer.connect("timeout", self, "wander"),
		$PlayerScoutArea.connect("body_entered", self, "check_if_player_entered"),
	])

func _process(delta):
	var dist := dest - global_position
	var moveAmt = kMoveSpeed * delta
	if dist.length() > moveAmt:
		var _vel = move_and_collide(dist.normalized() * moveAmt)
	else:
		var _vel = move_and_collide(dist)
	if dist.x < -0.1:
		$Graphics.scale.x = -0.14
	elif dist.x > 0.1:
		$Graphics.scale.x = 0.14
		
	if state == State.Chase:
		dest = closest_chase_dest()
		
	var rotationAmt := kAnimationRotation * cos(2 * PI * $AnimationTimer.time_left / $AnimationTimer.wait_time)
	$Graphics/Body1/Head.rotation_degrees = rotationAmt
	$Graphics/Body1/Body2.rotation_degrees = -rotationAmt
	$Graphics/Body1/Body2/Body3.rotation_degrees = -rotationAmt
