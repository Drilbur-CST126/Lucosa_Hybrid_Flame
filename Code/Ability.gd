extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

const Ability = GlobalData.Ability

export(Ability) var ability

var popup
var player: Ruicosa
var inArea := false

func player_entered(playerNode: Node2D):
	popup = ButtonPopup.instance()
	popup.curButton = popup.Buttons.Up
	playerNode.add_child(popup)
	player = playerNode
	inArea = true
	
func player_exited(playerNode: Node2D):
	popup.queue_free()
	player = null
	inArea = false
	
func has_ability() -> bool:
	match ability:
		Ability.Dive:
			return GlobalData.hasDive
		Ability.Fireball:
			return GlobalData.hasFireball
		Ability.Uppercut:
			return GlobalData.hasUppercut
	return false

func _ready():
	if has_ability():
		queue_free()
	
func _process(delta):
	if !Engine.editor_hint && inArea && Input.is_action_just_pressed("ui_up"):
		var popup
		match ability:
			Ability.Dive:
				popup = load("res://Menu/AbilityPopups/Dive.tscn").instance()
				GlobalData.hasDive = true
			Ability.Fireball:
				popup = load("res://Menu/AbilityPopups/Fireball.tscn").instance()
				GlobalData.hasFireball = true
			Ability.Uppercut:
				popup = load("res://Menu/AbilityPopups/Uppercut.tscn").instance()
				GlobalData.hasUppercut = true
				player.canDoubleJump = true
		
		popup.player = player
		GlobalData.hud.add_child(popup)
		player.play_anim("Idle", true)
		player.velocity = Vector2.ZERO
		player.state = player.ActionState.Stun
		queue_free()
