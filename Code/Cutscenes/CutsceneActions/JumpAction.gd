extends CutsceneAction

func activate():
	.activate()
	cutscene.mockPlayer.jump()
	finish()
