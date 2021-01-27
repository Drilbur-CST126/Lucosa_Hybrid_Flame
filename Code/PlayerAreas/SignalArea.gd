extends PlayerArea

export var oneoff := true

signal has_player()

func player_entered(_player: Node2D):
	emit_signal("has_player")
	if oneoff:
		queue_free()
