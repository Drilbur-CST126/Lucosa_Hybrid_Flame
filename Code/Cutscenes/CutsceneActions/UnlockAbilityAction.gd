extends CutsceneAction

export(GlobalData.Ability) var ability
export(String, FILE, "*.tscn, *.scn") var abilityTutorial

func activate():
	.activate()
	
	GlobalData.unlock_ability(ability)
	
	var player := cutscene.player
	var popup = load(abilityTutorial).instance()
	popup.player = cutscene.player
	GlobalData.hud.add_child(popup)
	player.play_anim("Idle", true)
	player.velocity = Vector2.ZERO
	player.state = player.ActionState.Stun
	
	finish()
