tool
extends Polygon2D

export var vertices := 32 setget set_vertices
export var diameter := 10.0 setget set_diameter

func set_vertices(val: int):
	vertices = val
	update_polygon()
	
func set_diameter(val: float):
	diameter = val
	update_polygon()
	
func update_polygon():
	var points := PoolVector2Array()
	var uv_ := PoolVector2Array()
	var colors := PoolColorArray([color])
	points.push_back(Vector2(0, 0))
	uv_.push_back(Vector2(0.5, 0.5))
	
	for i in range(vertices + 1):
		var degreesRad := i * 2.0 * PI / vertices
		points.push_back(diameter * Vector2(cos(degreesRad), sin(degreesRad)))
		uv_.push_back(Vector2(cos(degreesRad) + 1, sin(degreesRad) + 1) / 2.0)
	
	polygon = points
	vertex_colors = colors
	uv = uv_;
	
func _ready():
	update_polygon()
