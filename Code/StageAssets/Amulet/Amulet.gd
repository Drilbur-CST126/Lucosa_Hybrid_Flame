extends InteractArea

var Popup := load("res://Menu/AbilityPopups/ExplosionImmunity.tscn")

var timePassed := 0.0

func action():
	var popup = Popup.instance()
	GlobalData.hasExplosionImmunity = true
		
	popup.player = player
	GlobalData.hud.add_child(popup)
	player.play_anim("Idle", true)
	player.velocity = Vector2.ZERO
	player.state = player.ActionState.Stun
	queue_free()
	
func _process(delta):
	timePassed += delta
	$Amulet.position.y = 2.0 * sin(timePassed / 3.0)
