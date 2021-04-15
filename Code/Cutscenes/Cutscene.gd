extends Node2D
class_name Cutscene

export var playerPath: NodePath

var player: Ruicosa
var curAction := -1
var mockPlayer: MockPlayer

func begin_cutscene():
	player = get_node(playerPath) as Ruicosa
	mockPlayer = player.begin_cutscene()
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	increment_action()
	
func start_action(action):
	Utility.print_errors([
		action.connect("finished", self, "finish_action", [action]),
	])
	action.activate()
	
func finish_action(action):
	action.disconnect("finished", self, "finish_action")
	increment_action()
	
func increment_action():
	curAction += 1
	if curAction < get_child_count():
		var action := get_child(curAction)
		start_action(action)
	else:
		player.end_cutscene(mockPlayer)
		get_tree().paused = false
