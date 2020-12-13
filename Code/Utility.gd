tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func lerp_color(from: Color, to: Color, val: float):
	return Color(lerp(from.r, to.r, val), \
			lerp(from.g, to.g, val), \
			lerp(from.b, to.b, val), \
			lerp(from.a, to.a, val))
			
func print_connect_errors(path: String, connections: Array):
	for i in connections:
		assert(i == 0, "Connection failed in " + path + "!")
		
func remove_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		
func contains(container, object) -> bool:
	for i in container:
		if i == object:
			return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
