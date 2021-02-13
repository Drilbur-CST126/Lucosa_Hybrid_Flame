extends Node
class_name DialogueArray


class DialogueContainer:
	var dialogue
	var array
	
	func _init(init_dialogue, init_array):
		dialogue = init_dialogue
		array = init_array

class Dialogue:
	extends Node
	
	var text: String
	var speaker = null

	func _init(dict: Dictionary, _parent):
		text = dict["text"]
		if dict.has("speaker"):
			speaker = dict["speaker"]

class DialogueBranch:
	extends Node
	
	var dialogue: Dialogue
	var options: Array
	
	func _init(script: GDScript, dict: Dictionary, parent):
		dialogue = Dialogue.new(dict["dialogue"], parent)
		for i in dict["options"]:
			options.append(i["text"])
			var new_path = script.new(i["path"], parent)
			add_child(new_path)
		add_child(dialogue)


var current := 0
var parent = null

func _init(array: Array, init_parent = null):
	parent = init_parent
	for dict in array:
		match dict["type"]:
			"Dialogue":
				add_child(Dialogue.new(dict, self))
			"Branch":
				add_child(DialogueBranch.new(get_script(), dict, self))
				
func get_first() -> DialogueContainer:
	current = -1
	return next()
				
func next() -> DialogueContainer:
	current += 1
	if get_child_count() > current:
		return DialogueContainer.new(get_children()[current], self)
	elif parent != null:
		return parent.next()
	else:
		return null
