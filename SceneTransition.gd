extends Area2D
tool

var TransitionEffect = preload("res://Code/Polish/TransitionEffect.tscn")

export var colDimensions := Vector2(0.0, 0.0) setget set_col_dimensions
export(String, FILE, "*.tscn,*.scn") var loadPath

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_col_dimensions(val: Vector2):
	colDimensions = val
	var shape := RectangleShape2D.new()
	shape.extents = val
	$CollisionShape2D.shape = shape

# Called when the node enters the scene tree for the first time.
func _ready():
	($CollisionShape2D.shape as RectangleShape2D).extents = colDimensions
	connect("body_entered", self, "entered")

func entered(unit: Node):
	if !Engine.editor_hint and unit.name == "Toxen":
		GlobalData.emit_signal("trans_begin", GlobalData.Direction.Ltr, loadPath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
