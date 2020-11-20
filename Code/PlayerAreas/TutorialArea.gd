tool
extends "res://Code/PlayerArea.gd"

export var size := Vector2(10.0, 10.0) setget set_size
export(String, FILE, "*.tscn,*.scn") var popup
export var waitTime := 0.0

var tutorial: Control = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_size(val: Vector2):
	size = val
	$CollisionShape2D.shape.extents = size
	
func create_prompt():
	tutorial = load(popup).instance()
	GlobalData.hud.add_child(tutorial)

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = size
	Utility.print_connect_errors(get_path(), [
		$Timer.connect("timeout", self, "create_prompt")
	])

func player_entered(player: Node2D):
	if waitTime > 0.0:
		$Timer.start(waitTime)
	else:
		create_prompt()

func player_exited(player: Node2D):
	$Timer.stop()
	if tutorial != null:
		tutorial.unload()
		tutorial = null
