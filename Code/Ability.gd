extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

const Ability = GlobalData.Ability

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
		Ability.Fireball:
			return GlobalData.hasFireball
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
				var divePopup := load("res://Menu/AbilityPopups/Dive.tscn")
				GlobalData.hud.add_child(divePopup.instance())
				GlobalData.hasDive = true
			Ability.Fireball:
				var fireballPopup := load("res://Menu/AbilityPopups/Fireball.tscn")
				GlobalData.hud.add_child(fireballPopup.instance())
				GlobalData.hasFireball = true
		queue_free()
