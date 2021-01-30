tool
extends Polygon2D

export var outlineColor := Color(0, 0, 0, 1) setget set_outline_color
export var width := 3.0 setget set_width

func set_outline_color(val: Color):
	outlineColor = val
	update()

func set_width(val: float):
	width = val
	update()

func _draw():
	var poly := get_polygon()
	if poly.size() >= 3:
		for i in range(1, poly.size()):
			draw_line(poly[i-1], poly[i], outlineColor, width, true)
		draw_line(poly[0], poly[poly.size()-1], outlineColor, width, true)
