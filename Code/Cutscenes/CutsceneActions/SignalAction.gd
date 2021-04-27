extends CutsceneAction

signal signal_action()

func activate():
	.activate()
	
	emit_signal("signal_action")
	
	finish()
