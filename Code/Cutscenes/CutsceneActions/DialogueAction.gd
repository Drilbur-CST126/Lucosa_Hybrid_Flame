extends CutsceneAction

export(String, FILE, "*.json") var dialoguePath

func activate():
	.activate()
	var dialogueBox = GlobalData.hud.show_dialogue_box(dialoguePath) as Node
	
	Utility.print_errors([
		dialogueBox.connect("dialogue_finished", self, "finish"),
	])
