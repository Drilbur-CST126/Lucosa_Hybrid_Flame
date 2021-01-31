tool
extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")
const kColors := [Color("#ffff00"), Color("#00ffff"), Color("#ff00ff")]

enum Type { Life = 0, Damage = 1, Foresight = 2 }

export(Type) var type setget set_type

var popup
var player: Ruicosa
var inArea := false
var lifetime := 0.0

func set_type(val):
	type = val
	$Sprite.region_rect.position.x = 50 * val
	$Circle.material.set_shader_param("color", kColors[val])

func collected_str() -> String:
	return String(get_path()) + "_collected"

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

func _ready():
	if !Engine.editor_hint && GlobalData.flags.has(collected_str()):
		queue_free()
		
func _process(delta):
	if !Engine.editor_hint && inArea && Input.is_action_just_pressed("ui_up"):
		match type:
			Type.Life:
				GlobalData.playerMaxHp += 1
			Type.Damage:
				GlobalData.playerAttackDmg += 1
			Type.Foresight:
				GlobalData.playerForesight += 1
		GlobalData.flags.append(collected_str())
		queue_free()
		
	lifetime += delta
	$Circle.diameter = lerp(16, 24, cos(lifetime) * cos(lifetime))
