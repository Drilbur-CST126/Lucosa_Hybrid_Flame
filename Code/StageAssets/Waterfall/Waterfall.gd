extends Node2D
tool

export(int, 1, 20) var height := 1 setget set_height
export var showMist := true setget set_show_mist
export var mistOffset := 0.0 setget set_mist_offset

func set_height(val: int):
	height = val
	update_waterfall()
	
func set_show_mist(val: bool):
	showMist = val
	if has_node("Mist"):
		$Mist.visible = val
	
func set_mist_offset(val: float):
	mistOffset = val
	if has_node("Mist"):
		$Mist.position.y = val
	
func _ready():
	update_waterfall()

func update_waterfall():
	if has_node("WaterfallSprite"):
		$WaterfallSprite.region_rect.size.y = 1080 * height
		$WaterfallSprite.position.y = -90 * height
	if $Particles.get_child_count() < height: # Need to add more children
		for i in range($Particles.get_child_count(), height):
			var particle := $Particles/Particles2D.duplicate() as Particles2D
			particle.position.y -= 180 * i
			$Particles.add_child(particle)
	elif $Particles.get_child_count() > height: # Need to remove some children
		for i in range(height, $Particles.get_child_count()):
			$Particles.get_child(i).queue_free()
