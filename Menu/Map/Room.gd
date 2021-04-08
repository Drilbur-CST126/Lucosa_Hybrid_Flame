extends Polygon2D

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
