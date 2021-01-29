extends "res://Code/PlayerArea.gd"

func player_entered(player: Node2D):
	player.knockback(self, 1, false)
	$CollisionShape2D.set_deferred("disabled", true)
