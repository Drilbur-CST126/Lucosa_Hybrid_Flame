tool
extends Polygon2D
class_name OutlinePolygon

export var outlineColor := Color(0, 0, 0, 1) setget set_outline_color
export var width := 3.0 setget set_width

func set_polygon(val):
	.set_polygon(val)
	update()

func set_outline_color(val: Color):
	outlineColor = val
	update()

func set_width(val: float):
	width = val
	update()

func update():
	.update()
	if get_node_or_null("Line2D") != null:
		$Line2D.points = polygon
		if polygon.size() > 0:
			$Line2D.add_point(polygon[0])
		$Line2D.width = width
		$Line2D.default_color = outlineColor
		
func _ready():
	update()
