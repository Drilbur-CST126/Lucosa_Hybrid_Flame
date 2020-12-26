extends Node2D

export var loadId: String
export var facingRight := false
export var onGround := true
export var jump := false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_class() -> String:
	return "RoomSpawnPoint"

func is_current_spawn() -> bool:
	return GlobalData.lastRoomId == loadId

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_current_spawn():
		if onGround:
			$RayCast2D.force_raycast_update()
			var colPoint: Vector2 = $RayCast2D.get_collision_point()
			global_position = colPoint
		position.y -= 10
		var player := get_parent().get_node_or_null(GlobalData.kPlayerClassName)
		if player != null:
			player.position = position
			player.facingRight = facingRight
			if jump:
				player.jump(true)
#		var camera := get_parent().get_node("DynamicCamera")
#		if camera != null:
#			camera.global_position = global_position
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
