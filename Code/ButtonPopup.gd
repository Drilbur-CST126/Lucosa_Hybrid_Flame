extends Node2D

enum Buttons {
	Up = 0,
	A = 1,
	Z = 2,
	X = 3
}

export(Buttons) var curButton := Buttons.Up setget set_cur_button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_cur_button(val):
	curButton = val
	$Sprite.region_rect.position.x = val * 96
	
func set_controller_pos(usingController: bool):
	$Sprite.region_rect.position.y = 96 if usingController else 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_controller_pos(GlobalData.usingController)
	Utility.print_connect_errors(get_path(),[GlobalData.connect("control_config_changed", self, "set_controller_pos")])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
