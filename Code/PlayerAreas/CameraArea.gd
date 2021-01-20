tool
extends "res://Code/PlayerArea.gd"

export var cameraBounds: Rect2 setget set_camera_bounds
var displayArea: ColorRect
var enableForce := true

func set_camera_bounds(val: Rect2):
	cameraBounds = val
	if displayArea != null:
		update_display_area()
		
func update_display_area():
	displayArea.margin_left = cameraBounds.position.x
	displayArea.margin_right = cameraBounds.end.x
	displayArea.margin_top = cameraBounds.position.y
	displayArea.margin_bottom = cameraBounds.end.y

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		displayArea = ColorRect.new()
		displayArea.color = Color(1.0, 1.0, 1.0, 0.3)
		update_display_area()
		add_child(displayArea)
	Utility.print_connect_errors(get_path(), [
		$DisableForceTimer.connect("timeout", self, "disable_force"),
	])
		
func player_entered(player: Node2D):
	var camera := GlobalData.camera
	camera.dynamicLimitLeft = cameraBounds.position.x
	camera.dynamicLimitRight = cameraBounds.end.x
	camera.dynamicLimitUp = cameraBounds.position.y
	camera.dynamicLimitDown = cameraBounds.end.y
	if enableForce:
		if GlobalData.oldCameraLimits == null:
			GlobalData.oldCameraLimits = [
				camera.limit_left,
				camera.limit_right,
				camera.limit_top,
				camera.limit_bottom,
			]
			camera.limit_left = camera.dynamicLimitLeft
			camera.limit_right = camera.dynamicLimitRight
			camera.limit_top = camera.dynamicLimitUp
			camera.limit_bottom = camera.dynamicLimitDown
		camera.global_position = player.global_position
		camera.force_camera_to_pos()
		
func disable_force():
	enableForce = false
	if GlobalData.oldCameraLimits != null:
		var camera := GlobalData.camera
		camera.limit_left = GlobalData.oldCameraLimits[0]
		camera.limit_right = GlobalData.oldCameraLimits[1]
		camera.limit_top = GlobalData.oldCameraLimits[2]
		camera.limit_bottom = GlobalData.oldCameraLimits[3]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
