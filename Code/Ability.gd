extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

const Ability = GlobalData.Ability

export(Ability) var ability

var popup
var player
var inArea := false

func player_entered(playerNode: Node2D):
	playerNode.add_child(popup)
	player = playerNode
	inArea = true
	
func player_exited(playerNode: Node2D):
	playerNode.remove_child(popup)
	player = null
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
				var divePopup = load("res://Menu/AbilityPopups/Dive.tscn").instance()
				divePopup.player = player
				GlobalData.hud.add_child(divePopup)
				GlobalData.hasDive = true
			Ability.Fireball:
				var fireballPopup = load("res://Menu/AbilityPopups/Fireball.tscn").instance()
				fireballPopup.player = player
				GlobalData.hud.add_child(fireballPopup)
				GlobalData.hasFireball = true
		player.play_anim("Idle", true)
		player.velocity = Vector2.ZERO
		player.state = player.ActionState.Stun
		queue_free()
