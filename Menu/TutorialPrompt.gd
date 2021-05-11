tool
extends Control
class_name TutorialPopup

const Buttons = preload("res://Code/ButtonPopup.gd").Buttons

export var displayText := "Content" setget set_display_text
export(Buttons) var button setget set_button

var center := Vector2(0.0, 33.0)

func set_display_text(text):
	displayText = text
	$HBoxContainer/Label.text = text
	
func set_button(value):
	button = value
	$HBoxContainer/ButtonControl/ButtonPopup.curButton = button

func update_circle():
	var w := $HBoxContainer/ButtonControl.rect_size.x as float + $HBoxContainer/Label.rect_size.x as float
	center.x = $HBoxContainer.rect_size.x as float / 2.0
	center.y = $HBoxContainer.rect_position.y + 33
	$Circle.position = center
	$Circle.scale.x = w / $Circle.diameter
	
func unload():
	$AnimationPlayer.play_backwards("FadeIn")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	Utility.print_connect_errors(get_path(), [
		$HBoxContainer/Label.connect("resized", self, "update_circle")
	])
	set_display_text(displayText)
	#$HBoxContainer.rect_position.y = 720# - $HBoxContainer.rect_size.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
