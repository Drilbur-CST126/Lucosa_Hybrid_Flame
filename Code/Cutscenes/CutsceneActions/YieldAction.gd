extends CutsceneAction

export var duration := 1.0

func activate():
	.activate()
	
	yield(Utility.create_timer(self, duration), "timeout")
	
	finish()
