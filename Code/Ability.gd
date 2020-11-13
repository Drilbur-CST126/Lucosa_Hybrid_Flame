extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

enum Ability {
	Dive,
}

export(Ability) var ability

var popup
var inArea := false

func player_entered(player: Node2D):
	player.add_child(popup)
	inArea = true
	
func player_exited(player: Node2D):
	player.remove_child(popup)
	inArea = false
	
func has_ability() -> bool:
	match ability:
		Ability.Dive:
			return GlobalData.hasDive
	return false

func _ready():
	if has_ability():
		queue_free()
	
	popup = ButtonPopup.instance()
	popup.curButton = popup.Buttons.Up
	
func _process(delta):
	if !Engine.editor_hint && inArea && Input.is_action_just_pressed("ui_up"):
		match ability:
			Ability.Dive:
				GlobalData.hasDive = true
				var dive := load("res://Menu/AbilityPopups/Dive.tscn")
				get_parent().add_child(dive.instance())
		queue_free()
