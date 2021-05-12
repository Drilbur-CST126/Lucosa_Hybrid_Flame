extends Control
tool

var atlas: AtlasTexture

enum Buttons {
	Up = 0,
	A = 1,
	Z = 2,
	X = 3,
	C = 4,
	S = 5,
}

export(Buttons) var curButton := Buttons.Up setget set_cur_button
export var buttonScale := Vector2(1, 1) setget set_button_scale

func set_cur_button(val):
	curButton = val
	if atlas != null:
		atlas.region.position.x = val * 96
		
func set_button_scale(val: Vector2):
	buttonScale = val
	if has_node("TextureRect"):
		$TextureRect.rect_scale = buttonScale
		$TextureRect.anchor_bottom = 1.0 / buttonScale.y
		$TextureRect.anchor_right = 1.0 / buttonScale.x
	
func set_controller_pos(usingController: bool):
	if atlas != null:
		atlas.region.position.y = 96 if usingController else 0

func _ready():
	$TextureRect.texture = $TextureRect.texture.duplicate()
	atlas = $TextureRect.texture as AtlasTexture
	set_cur_button(curButton)
	set_button_scale(buttonScale)
	if !Engine.editor_hint:
		set_controller_pos(GlobalData.usingController)
	Utility.print_connect_errors(get_path(),[GlobalData.connect("control_config_changed", self, "set_controller_pos")])
