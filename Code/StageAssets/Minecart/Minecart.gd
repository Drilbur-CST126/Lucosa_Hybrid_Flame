extends Node2D

var player: Node2D = null

func _ready():
	Utility.print_connect_errors(get_path(), [
		$LowerArea2D.connect("body_entered", self, "lower_entered"),
	])
	
func _process(_delta):
	if player != null:
		if Input.is_action_just_pressed("jump"):
			player.jump(true)
			player = null
	
func lower_entered(other: Node2D):
	if other.get_class() == GlobalData.kPlayerClassName:
		other.state = other.ActionState.InMinecart
		other.play_anim("Idle", true)
		player = other
