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
	if get_node_or_null("OLDLine2D") != null:
		$OLDLine2D.points = polygon
		if polygon.size() > 0:
			$OLDLine2D.add_point(polygon[0])
		$OLDLine2D.width = width
		$OLDLine2D.default_color = outlineColor
		
func _ready():
	update()
