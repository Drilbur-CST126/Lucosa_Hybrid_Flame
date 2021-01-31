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
		
func print_errors(calls: Array):
	for i in calls:
		if i != 0:
			printerr("Godot Error found! Error: " + i)
			print_stack()
		
		
func remove_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		
func contains(container, object) -> bool:
	for i in container:
		if i == object:
			return true
	return false
	
func create_timer(node: Node, duration: float) -> Timer:
	var timer := Timer.new()
	node.add_child(timer)
	timer.start(duration)
	print_connect_errors(get_path(), [
		timer.connect("timeout", timer, "queue_free"),
	])
	return timer
	
func get_dir(facingRight: bool) -> int:
	return 1 if facingRight else -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
