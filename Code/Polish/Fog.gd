extends Node2D
tool

export var color := Color(1.0, 1.0, 1.0, 1.0) setget set_color
export var width := 320.0 setget set_width
export var extraHeight := 0.0 setget set_height
export var speed := 20.0 setget set_speed

var curPos := 0.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_color(value: Color):
	color = value
	$FogSprite.modulate = color
	$FogRect.modulate = color

func set_width(value: float):
	width = value
	$FogSprite.region_rect.size.x = width
	$FogRect.margin_left = -width / 2
	$FogRect.margin_right = width / 2

func set_height(value: float):
	extraHeight = value
	$FogRect.margin_bottom = 16 + extraHeight

func set_speed(value: float):
	speed = value

# Called when the node enters the scene tree for the first time.
func _ready():
	set_color(color)
	set_width(width)
	set_height(extraHeight)

func _process(delta):
	curPos += speed * delta
	$FogSprite.region_rect.position.x = curPos as int

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
