extends CutsceneAction

export var run := false

func activate():
	.activate()
	cutscene.mockPlayer.move_to(global_position.x, run)
	Utility.print_errors([
		cutscene.mockPlayer.connect("destination_reached", self, "finish"),
	])
