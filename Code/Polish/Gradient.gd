tool
extends Control

export var topColor := Color.white setget set_top_color
export var bottomColor := Color.black setget set_bottom_color

func set_top_color(val: Color):
	topColor = val
	update()

func set_bottom_color(val: Color):
	bottomColor = val
	update()

func _draw():
	draw_polygon([
		Vector2(0, rect_size.y),
		Vector2(rect_size.x, rect_size.y),
		Vector2(rect_size.x, 0),
		Vector2(0, 0),
	], [
		bottomColor, bottomColor, topColor, topColor
	])
