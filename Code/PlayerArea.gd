extends Area2D
class_name PlayerArea

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	Utility.print_connect_errors(get_path(),[
		connect("body_entered", self, "entered"),
		connect("body_exited", self, "exited")
	])

func entered(node: Node2D):
	if node is Ruicosa:
		player_entered(node)
		
func player_entered(_player: Node2D):
	pass
	
func exited(node: Node2D):
	if node is Ruicosa:
		player_exited(node)
		
func player_exited(_player: Node2D):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
