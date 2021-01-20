extends Node2D

const kWheelDiameter := 55.0
const kAcceleration := 48.0
const kMoveDuration := 1.5

export(String, FILE, "*.tscn,*.scn") var destination
export(int, 1, 99) var routeId := 1
export var movingRight := true

var player: Ruicosa = null
var velocity := 0.0
var wheelRad := 0.0
var moving := false

func get_room_id() -> String:
	return "in_minecart_" + String(routeId)

func _ready():
	Utility.print_connect_errors(get_path(), [
		$LowerArea2D.connect("body_entered", self, "lower_entered"),
	])
	if GlobalData.lastRoomId == get_room_id():
		player = get_parent().get_node_or_null(GlobalData.kPlayerClassName)
		if player != null:
			player.global_position = global_position - Vector2(0, 6)
			player.facingRight = !movingRight
	
func _process(delta):
	if player != null:
		if Input.is_action_just_pressed("jump"):
			player.jump(true)
			player = null
		if Input.is_action_just_pressed("attack"):
			begin_moving()
			
	if moving:
		velocity += Utility.get_dir(movingRight) * kAcceleration * delta
		position.x += velocity * delta
		if player != null:
			player.position.x += velocity * delta
		
		var rotVelocity := velocity / kWheelDiameter
		wheelRad += 2 * PI * rotVelocity * delta
		$Graphics/LeftWheel.rotation = wheelRad
		$Graphics/RightWheel.rotation = wheelRad
			
func begin_moving():
	GlobalData.camera.shake(1, 0.4)
	yield(GlobalData.camera, "shaking_finished")
	
	moving = true
	yield(Utility.create_timer(self, kMoveDuration), "timeout")
	
	var dirs := GlobalData.Direction
	GlobalData.transition_rooms(dirs.Rtl if movingRight else dirs.Ltr, destination, get_room_id())
	
func lower_entered(other: Node2D):
	if other is Ruicosa:
		other.state = other.ActionState.InMinecart
		other.play_anim("Idle", true)
		other.velocity = Vector2()
		player = other
