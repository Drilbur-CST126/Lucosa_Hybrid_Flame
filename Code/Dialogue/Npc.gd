extends InteractArea
class_name Npc

export(String, FILE, "*.json") var dialogueTree

func action():
	if player.is_on_floor():
		GlobalData.hud.show_dialogue_box(dialogueTree)
