tool
extends Node

const kInGameDimensions := Vector2(320, 180)

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func lerp_color(from: Color, to: Color, val: float):
	return Color(lerp(from.r, to.r, val), \
			lerp(from.g, to.g, val), \
			lerp(from.b, to.b, val), \
			lerp(from.a, to.a, val))
			
func color_change_alpha(src: Color, alpha: float):
	return Color(src.r, src.g, src.b, src.a * alpha)
			
func print_connect_errors(path: String, connections: Array):
	for i in connections:
		assert(i == 0, "Connection failed in " + path + "!")
		
func print_errors(calls: Array):
	for i in calls:
		if i != 0:
			printerr("Godot Error found! Error: " + String(i))
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
	
func set_font(src: Control, path: String):
	src.set("custom_fonts/font", load(path))
	
func select_option(option_dict: Dictionary):
	var rand := randf()
	#print(rand)
	for key in option_dict.keys():
		if option_dict[key] >= rand: # This key was chosen
			return key
		else: # This key was not chosen; subtract the odds of it occuring
			rand -= option_dict[key]
