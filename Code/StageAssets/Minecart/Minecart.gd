extends Node2D

const kWheelDiameter := 55.0
const kAcceleration := 48.0
const kMoveDuration := 1.5

export(String, FILE, "*.tscn,*.scn") var destination
export(int, 1, 99) var routeId := 1
export var movingRight := true
export var lockedDist := 320.0

var player: Ruicosa = null
var velocity := 0.0
var wheelRad := 0.0
var movingOut := false
var movingIn := false
var inMovingAnim := false

func get_room_id() -> String:
	return "in_minecart_" + String(routeId)
	
func get_unlocked_flag() -> String:
	return "minecart_line_" + String(routeId) + "_unlocked"
	
func moving() -> bool:
	return movingOut || movingIn

func _ready():
	if !GlobalData.flags.has(get_unlocked_flag()):
		position.x += lockedDist * Utility.get_dir(movingRight)
	
	Utility.print_connect_errors(get_path(), [
		$LowerArea2D.connect("body_entered", self, "lower_entered"),
	])
	if GlobalData.lastRoomId == get_room_id():
		player = get_parent().get_node_or_null(GlobalData.kPlayerClassName)
		if player != null:
			player.global_position = global_position - Vector2(0, 6)
			player.facingRight = !movingRight
	
func _process(delta):
	if !inMovingAnim && player != null:
		if Input.is_action_just_pressed("jump"):
			player.jump(true)
			player = null
		if Input.is_action_just_pressed("attack"):
			begin_moving()
			
	if moving():
		velocity += Utility.get_dir(movingRight) * delta \
				 * kAcceleration
		position.x += velocity * delta
		if player != null:
			player.position.x += velocity * delta
		
		var rotVelocity := velocity / kWheelDiameter
		wheelRad += 2 * PI * rotVelocity * delta
		$Graphics/LeftWheel.rotation = wheelRad
		$Graphics/RightWheel.rotation = wheelRad
		
func unlock():
	GlobalData.flags.append(get_unlocked_flag())
	# dist(0) = 0
	# dist(mt) = md
	# v(mt) = 0
	# dist(t) = v(0) * t - acc * t^2 / 2
	# md = v(0) * mt - acc * mt^2 / 2
	# v(0) * mt = md + acc * mt^2 / 2
	# v(0) = md / mt + acc * mt / 2
	# v(t) = v(0) - acc * t
	# 0 = md / mt + acc * mt / 2 - acc * mt
	# 0 = md / mt - acc * mt / 2
	# acc * mt = 2 * md / mt
	# mt^2 = 2 * md / acc
	var moveTime := sqrt(2 * lockedDist / kAcceleration)
	velocity = lockedDist / moveTime + kAcceleration * moveTime / 2.0
	movingIn = true
	inMovingAnim = true
	
	yield(Utility.create_timer(self, moveTime), "timeout")
	movingIn = false
	inMovingAnim = false
	velocity = 0.0
			
func begin_moving():
	inMovingAnim = true
	GlobalData.camera.shake(1, 0.4)
	yield(GlobalData.camera, "shaking_finished")
	
	movingOut = true
	yield(Utility.create_timer(self, kMoveDuration), "timeout")
	
	var dirs := GlobalData.Direction
	GlobalData.transition_rooms(dirs.Rtl if movingRight else dirs.Ltr, destination, get_room_id())
	
func lower_entered(other: Node2D):
	if other is Ruicosa:
		other.state = other.ActionState.InMinecart
		other.play_anim("Idle", true)
		other.velocity = Vector2()
		player = other
