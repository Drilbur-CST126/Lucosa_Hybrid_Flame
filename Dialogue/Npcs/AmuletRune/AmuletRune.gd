extends Npc

func parse_dialogue_signal(signal_name: String):
	if signal_name == "drop_amulet" && !GlobalData.hasExplosionImmunity:
		var _enemy = $ArenaSpawn.spawn_enemy()
		$CollisionShape2D.set_deferred("disabled", true)
