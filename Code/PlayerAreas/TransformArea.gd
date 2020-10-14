tool
extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

export var size := Vector2(10.0, 10.0) setget set_size

var buttonPopup

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_size(val: Vector2):
	size = val
	$CollisionShape2D.shape.extents = size
	$ColorRect.margin_bottom = size.y
	$ColorRect.margin_top = -size.y
	$ColorRect.margin_left = -size.x
	$ColorRect.margin_right = size.x

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = size

func player_entered(player: Node2D):
	GlobalData.canTransform = true
	buttonPopup = ButtonPopup.instance()
	buttonPopup.curButton = buttonPopup.Buttons.A
	player.add_child(buttonPopup)

func player_exited(player: Node2D):
	# Player can still transform if they can anywhere
	GlobalData.canTransform = GlobalData.canTransformAnywhere
	player.remove_child(buttonPopup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
