extends Node2D

export var loadId: String
export var facingRight := false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if GlobalData.lastRoomId == loadId:
		$RayCast2D.force_raycast_update()
		var colPoint: Vector2 = $RayCast2D.get_collision_point()
		global_position = colPoint
		position.y -= 10
		var player := get_parent().get_node_or_null(GlobalData.kPlayerClassName)
		if player != null:
			player.position = position
			if facingRight:
				player.facingRight = true
		var camera := get_parent().get_node_or_null("DynamicCamera")
		if camera != null:
			camera.global_position = global_position
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
