extends Polygon2D

export var glowColor: Color
var defaultColor = null
var glowTimer := 0.0

func _ready():
	defaultColor = color

func get_center() -> Vector2:
	var left
	var right
	var up
	var down
	
	for point in polygon:
		if left == null || point.x < left:
			left = point.x
		if right == null || point.x > right:
			right = point.x
		if up == null || point.y < up:
			up = point.y
		if down == null || point.y > down:
			down = point.y
			
	return position + Vector2((left + right) / 2.0, (up + down) / 2.0)
	
func process_glow(delta):
	if defaultColor != null:
		glowTimer += delta
		color = Utility.lerp_color(defaultColor as Color, glowColor, (sin(3.0 * glowTimer) + 1.0) / 2.0)
