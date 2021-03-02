extends InteractArea
class_name Npc

export(String, FILE, "*.json") var dialogueTree

func action():
	if player.is_on_floor():
		var box = GlobalData.hud.show_dialogue_box(dialogueTree)
		Utility.print_errors([
			box.connect("dialogue_signal", self, "parse_dialogue_signal"),
		])

func parse_dialogue_signal(signal_name: String):
	print(signal_name)
