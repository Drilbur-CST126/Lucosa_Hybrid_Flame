tool
extends Node2D
class_name SpecificVisibilityNotifier

export var area := Rect2() setget set_area
export var initCheck := true

var onScreen := false setget set_on_screen

signal screen_entered()
signal screen_exited()

func set_on_screen(val: bool):
	onScreen = val
	if val:
		emit_signal("screen_entered")
	else:
		emit_signal("screen_exited")
		
func set_area(val: Rect2):
	area = val
	update()
		
func _draw():
	if Engine.editor_hint:
		draw_rect(area, Color(1, 0, 1, 0.2))

func _process(_delta):
	if !Engine.editor_hint:
		if initCheck:
			do_init_check()
		else:
			var rect := calc_camera_area()
			var hasPoint := rect.has_point(global_position) if area.has_no_area() \
					else rect.intersects(get_relative_area())
			
			if hasPoint && !onScreen:
				set_on_screen(true)
			if !hasPoint && onScreen:
				set_on_screen(false)
			
func do_init_check():
	initCheck = false
	var rect := calc_camera_area()
	var hasPoint := rect.has_point(global_position) if area.has_no_area() \
			else rect.intersects(get_relative_area())
	set_on_screen(hasPoint)
		
func get_relative_area() -> Rect2:
	return Rect2(area.position + global_position, area.size)
		
static func calc_camera_area() -> Rect2:
	var camera := GlobalData.camera
	var halfSize := Utility.kInGameDimensions / 2.0
	return Rect2(camera.get_camera_screen_center() - halfSize, Utility.kInGameDimensions)
