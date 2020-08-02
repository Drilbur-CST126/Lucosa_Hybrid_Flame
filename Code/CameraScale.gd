extends Node2D

onready var viewport := get_viewport()

func set_previous_screen():
	GlobalData.lastRoom = name

func _ready():
	get_tree().connect("screen_resized", self, "_screen_resized")
	connect("ready", self, "set_previous_screen")

func _screen_resized():
	var window_size := OS.get_window_size()
#	if window_size.x > window_size.y * 16 / 9:
#		window_size.x = window_size.y * 16 / 9
#	elif window_size.x < window_size.y * 16 / 9:
#		window_size.y = window_size.x * 9 / 16

	# see how big the window is compared to the viewport size
	# floor it so we only get round numbers (0, 1, 2, 3 ...)
	var scale_x := floor(window_size.x / viewport.size.x)
	var scale_y := floor(window_size.y / viewport.size.y)

	# use the smaller scale with 1x minimum scale
	var scale := max(1, min(scale_x, scale_y))

	# find the coordinate we will use to center the viewport inside the window
	var diff := window_size - (viewport.size * scale)
	var diffhalf := (diff * 0.5).floor()

	# attach the viewport to the rect we calculated
	viewport.set_attach_to_screen_rect(Rect2(diffhalf, viewport.size * scale))
#	$Toxen/Camera2D.limit_left = limit_l + diff.x / 2.0 / scale
#	$Toxen/Camera2D.limit_right = limit_r - diff.x / 2.0 / scale
#	$Toxen/Camera2D.limit_top = limit_u + diff.y / 2.0 / scale
#	$Toxen/Camera2D.limit_bottom = limit_d - diff.y / 2.0 / scale
	#$Toxen/Camera2D.zoom = window_size_f / (viewport_size_f * scale)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
