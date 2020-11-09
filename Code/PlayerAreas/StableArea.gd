extends "res://Code/PlayerArea.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var raycast := RayCast2D.new()
var playerNode: Node2D

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if raycast.enabled:
		var colPoint := raycast.get_collision_point()
		colPoint.y -= 11.5
		playerNode.respawnPos = colPoint
	
func player_entered(player: Node2D):
	raycast.enabled = true
	playerNode = player
	player.add_child(raycast)
	
func player_exited(player: Node2D):
	player.remove_child(raycast)
	raycast.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
