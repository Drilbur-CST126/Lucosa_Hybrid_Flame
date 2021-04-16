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
		for i in dict["options"]:
			options.append(i["text"])
			var new_path = script.new(i["path"], parent)
			add_child(new_path)
		match dict["dialogue"]["type"]:
			"Dialogue":
				dialogue = Dialogue.new(dict["dialogue"], parent)
				add_child(dialogue)
			"Cond":
				var dialogueCond := DialogueCond.new(script, dict["dialogue"], parent)
				dialogue = dialogueCond.get_path().get_first().dialogue
				add_child(dialogueCond)
		
class DialogueCond:
	extends Node
	
	var cond: String
	var parent = null
	var truePath = null
	var falsePath = null
	
	func _init(script: GDScript, dict: Dictionary, p):
		cond = dict["condition"]
		parent = p
		if dict.has("true"):
			truePath = script.new(dict["true"], parent)
			add_child(truePath)
		if dict.has("false"):
			falsePath = script.new(dict["false"], parent)
			add_child(falsePath)
		
	func is_true() -> bool:
		match cond:
			"lucosaForm":
				return GlobalData.lucosaForm
			"hasPreviousChargeAttack":
				return GlobalData.maxCharges > 1
		return false
		
	func get_path():
		return truePath if is_true() else falsePath
		
class DialogueEvent:
	extends Node
	
	var event: String
	var params: Dictionary
	
	func _init(dict: Dictionary, _parent):
		for key in dict:
			if key == "event":
				event = dict["event"]
			elif key != "type":
				params[key] = dict[key]


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
			"Cond":
				add_child(DialogueCond.new(get_script(), dict, self))
			"Event":
				add_child(DialogueEvent.new(dict, self))
				
func get_first() -> DialogueContainer:
	current = -1
	return next()
				
func next() -> DialogueContainer:
	current += 1
	if get_child_count() > current:
		var container := DialogueContainer.new(get_children()[current], self)
		while container != null && container.dialogue is DialogueCond:
			var nextPath = container.dialogue.get_path()
			if nextPath == null:
				container = next()
			else:
				container = nextPath.get_first()
		pass
		return container
	elif parent != null:
		return parent.next()
	else:
		return null
