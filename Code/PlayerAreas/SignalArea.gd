extends PlayerArea

export var oneoff := true

var player: Ruicosa

signal has_player()

func player_entered(p: Node2D):
	if p is Ruicosa:
		player = p
	emit_signal("has_player")
	if oneoff:
		queue_free()
		
func player_exited(_p: Node2D):
	player = null
