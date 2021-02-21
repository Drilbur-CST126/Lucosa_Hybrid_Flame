tool
extends Node2D
class_name Charge

const kFillHeight := 71

export(float, 0, 100) var fill = 100 setget set_fill

func set_fill(val: int):
	fill = val
	#$Fill.region_rect.end.y = int(kFillHeight * (fill / 100.0))
	$Fill.region_rect.position.y = int(kFillHeight * (1 - (fill / 100.0)))
	$Fill.position.y = kFillHeight * (1 - (fill / 100.0)) - 1

func set_empty():
	self.fill = 0
	
func set_full():
	self.fill = 100
