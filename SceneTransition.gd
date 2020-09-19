extends Area2D
tool

var TransitionEffect = preload("res://Code/Polish/TransitionEffect.tscn")
var ready := false

export var colDimensions := Vector2(0.0, 0.0) setget set_col_dimensions
export(GlobalData.Direction) var direction = GlobalData.Direction.Ltr
export(String, FILE, "*.tscn,*.scn") var loadPath
export var overrideLoadId := ""

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_col_dimensions(val: Vector2):
	colDimensions = val
	var shape := RectangleShape2D.new()
	shape.extents = val
	if ready:
		$CollisionShape2D.shape = shape

# Called when the node enters the scene tree for the first time.
func _ready():
	($CollisionShape2D.shape as RectangleShape2D).extents = colDimensions
	connect("body_entered", self, "entered")
	ready = true
	var shape := RectangleShape2D.new()
	shape.extents = colDimensions
	$CollisionShape2D.shape = shape

func entered(unit: Node):
	if !Engine.editor_hint and unit.get_class() == GlobalData.kPlayerClassName:
		GlobalData.emit_signal("trans_begin", direction, loadPath)
		GlobalData.transDirection = direction
		if overrideLoadId != "":
			GlobalData.lastRoomId = overrideLoadId
		else:
			GlobalData.lastRoomId = get_parent().name

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
