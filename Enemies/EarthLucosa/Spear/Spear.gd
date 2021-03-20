extends PlayerArea

func _ready():
	Utility.print_errors([
		$LifeTimer.connect("timeout", self, "queue_free"),
	])

func player_entered(player: Node2D):
	(player as Ruicosa).knockback(null, 1)
	queue_free()
