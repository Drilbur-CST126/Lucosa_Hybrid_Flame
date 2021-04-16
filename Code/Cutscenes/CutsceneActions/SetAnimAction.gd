extends CutsceneAction

export var anim: String

func activate():
	.activate()
	
	cutscene.mockPlayer.play_anim(anim)
	
	finish()
