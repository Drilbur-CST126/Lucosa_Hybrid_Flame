extends Node2D
tool

export(int, 1, 20) var height := 1 setget set_height

func set_height(val: int):
	height = val
	update_waterfall()
	
func _ready():
	update_waterfall()

func update_waterfall():
	$ColorRect.margin_top = -180 * height
	if $Particles.get_child_count() < height: # Need to add more children
		for i in range($Particles.get_child_count(), height):
			var particle := $Particles/Particles2D.duplicate() as Particles2D
			particle.position.y -= 180 * i
			$Particles.add_child(particle)
	elif $Particles.get_child_count() > height: # Need to remove some children
		for i in range(height, $Particles.get_child_count()):
			$Particles.get_child(i).queue_free()
