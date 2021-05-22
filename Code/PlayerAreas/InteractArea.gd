extends PlayerArea
class_name InteractArea

const ButtonPopup := preload("res://Code/ButtonPopup.tscn")
const Buttons := preload("res://Code/ButtonPopup.gd").Buttons

const kButtonMap := {
	Buttons.Up: "ui_up",
	Buttons.A: "transform",
	Buttons.Z: "jump",
	Buttons.X: "attack",
	Buttons.C: "second_attack",
}

export(Buttons) var popupIcon

var buttonPopup
var player: Node2D

func action():
	printerr("Error: InteractArea without an action!")

func player_entered(p: Node2D):
	player = p
	buttonPopup = ButtonPopup.instance()
	buttonPopup.curButton = popupIcon
	player.add_child(buttonPopup)

func player_exited(_p: Node2D):
	player.remove_child(buttonPopup)
	buttonPopup.queue_free()
	buttonPopup = null

func _process(_delta):
	if buttonPopup != null && Input.is_action_just_pressed(kButtonMap[popupIcon]):
		action()
