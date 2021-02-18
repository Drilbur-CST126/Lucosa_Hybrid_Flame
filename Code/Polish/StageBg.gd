tool
extends ColorRect
class_name StageBg

export var screen_size := Rect2(0, 0, 1, 1) setget set_screen_size

func set_screen_size(val: Rect2):
	screen_size = val
	margin_top = 180 * (val.position.y)
	margin_bottom = 180 * (val.size.y + val.position.y)
	margin_left = 320 * (val.position.x)
	margin_right = 320 * (val.size.x + val.position.x)
