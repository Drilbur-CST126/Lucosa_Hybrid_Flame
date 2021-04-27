extends CutsceneAction
tool

export var pathToNode: NodePath
export var speed := 128.0

var node: Node2D
var pathPoints: PoolVector2Array
var pathGlobalPos: Vector2
var pathIndex := 0

class PathData:
	extends Object
	var number: int
	var first: Path2D

func get_path_data() -> PathData:
	var pathData := PathData.new()
	for child in get_children():
		if child is Path2D:
			pathData.number += 1
			if pathData.first == null:
				pathData.first = child
	return pathData

func _get_configuration_warning():
	var paths := get_path_data().number
		
	if paths == 0:
		return "This node requires a Path2D."
	if paths > 1:
		return "This node has too many Path2Ds."
	return ""

func _ready():
	if !Engine.editor_hint:
		var pathData := get_path_data()
		if pathData.number != 1:
			printerr("MoveNodeAction has incorrect number of Path2D children.")
		else:
			pathPoints = pathData.first.curve.get_baked_points()
			pathGlobalPos = pathData.first.global_position
			node = get_node(pathToNode) as Node2D
			
func _process(delta):
	if activated && !Engine.editor_hint:
		var dist := ((pathPoints[pathIndex] + pathGlobalPos) - node.global_position)
		while activated && dist.length() < speed * delta:
			node.global_position = pathPoints[pathIndex]
			pathIndex += 1
			if pathIndex >= pathPoints.size():
				finish()
			else:
				dist = ((pathPoints[pathIndex] + pathGlobalPos) - node.global_position)
		if activated:
			var velocity := dist.normalized() * speed
			node.global_position += velocity * delta
		
