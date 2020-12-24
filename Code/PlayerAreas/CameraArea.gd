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
		
func player_entered(_player: Node2D):
	var camera := GlobalData.camera
	camera.dynamicLimitLeft = cameraBounds.position.x
	camera.dynamicLimitRight = cameraBounds.end.x
	camera.dynamicLimitUp = cameraBounds.position.y
	camera.dynamicLimitDown = cameraBounds.end.y
	if enableForce:
		camera.global_position = camera.get_target_pos()
		camera.force_update_transform()
		(camera as Camera2D).force_update_scroll()
		
func disable_force():
	enableForce = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
