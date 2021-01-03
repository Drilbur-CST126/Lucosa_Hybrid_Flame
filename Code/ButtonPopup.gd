tool
extends Node2D

enum Buttons {
	Up = 0,
	A = 1,
	Z = 2,
	X = 3,
	C = 4,
}

export(Buttons) var curButton := Buttons.Up setget set_cur_button
export var elevated := true setget set_elevated

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_elevated(val: bool):
	elevated = val
	if val:
		$Sprite.position.y = -20
	else:
		$Sprite.position.y = 0

func set_cur_button(val):
	curButton = val
	$Sprite.region_rect.position.x = val * 96
	
func set_controller_pos(usingController: bool):
	$Sprite.region_rect.position.y = 96 if usingController else 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Engine.editor_hint:
		set_controller_pos(GlobalData.usingController)
	Utility.print_connect_errors(get_path(),[GlobalData.connect("control_config_changed", self, "set_controller_pos")])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
