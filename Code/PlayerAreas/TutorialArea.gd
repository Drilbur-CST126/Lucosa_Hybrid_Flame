tool
extends "res://Code/PlayerArea.gd"

export var size := Vector2(10.0, 10.0) setget set_size
export(String, FILE, "*.tscn,*.scn") var popup
export var waitTime := 0.0

enum RequireForm { Ruirui, Lucosa, None }
export(RequireForm) var requiredForm = RequireForm.None

export(Array, GlobalData.Ability) var requiredAbilities = []

var tutorial: Control = null
var popupLoad

func set_size(val: Vector2):
	size = val
	$CollisionShape2D.shape.extents = size
	
func requirements_met() -> bool:
	# In the required form
	var met: bool = ((requiredForm == RequireForm.Ruirui && GlobalData.lucosaForm == false) \
			|| (requiredForm == RequireForm.Lucosa && GlobalData.lucosaForm == true)) \
			|| requiredForm == RequireForm.None
	
	# Having the required abilities
	for ability in requiredAbilities:
		met = met && GlobalData.has_ability(ability)
	
	return met
	
func create_prompt():
	tutorial = popupLoad.instance()
	GlobalData.hud.add_child(tutorial)

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = size
	Utility.print_connect_errors(get_path(), [
		$Timer.connect("timeout", self, "create_prompt")
	])
	
	popupLoad = load(popup)

func player_entered(player: Node2D):
	if requirements_met():
		if waitTime > 0.0:
			$Timer.start(waitTime)
		else:
			create_prompt()

func player_exited(player: Node2D):
	$Timer.stop()
	if tutorial != null:
		tutorial.unload()
		tutorial = null
