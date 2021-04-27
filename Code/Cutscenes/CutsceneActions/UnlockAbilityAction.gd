extends CutsceneAction

export(GlobalData.Ability) var ability
export(String, FILE, "*.tscn, *.scn") var abilityTutorial

func activate():
	.activate()
	
	GlobalData.unlock_ability(ability)
	cutscene.player.state = Ruicosa.ActionState.Stun
	var popup = load(abilityTutorial).instance()
	popup.player = cutscene.player
	GlobalData.hud.add_child(popup)
	
	finish()
