tool
extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")
#const DialogueBox = preload("res://Code/Dialogue/DialogueBox.tscn")

const kColors := [Color("#ffff00"), Color("#00ffff"), Color("#ff00ff")]
const kDialoguePaths := [
	"res://Dialogue/Upgrades/LifeRing.json",
	"res://Dialogue/Upgrades/Rune.json",
	"res://Dialogue/Upgrades/ForesightOrb.json",
]

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
	
func player_exited(_playerNode: Node2D):
	popup.queue_free()
	player = null
	inArea = false

func _ready():
	if !Engine.editor_hint && GlobalData.flags.has(collected_str()):
		queue_free()
	$Circle.material = $Circle.material.duplicate(true)
	$Circle.material.set_shader_param("color", kColors[type])
		
func _process(delta):
	if !Engine.editor_hint && inArea && Input.is_action_just_pressed("ui_up"):
		match type:
			Type.Life:
				GlobalData.playerMaxHp += 1
			Type.Damage:
				GlobalData.maxCharges += 1
			Type.Foresight:
				GlobalData.playerForesight += 1
				if GlobalData.playerForesight == 3:
					GlobalData.playerAttackDmg += 1
		GlobalData.flags.append(collected_str())
		GlobalData.hud.show_dialogue_box(kDialoguePaths[type])
		queue_free()
		
	lifetime += delta
	$Circle.diameter = lerp(16, 24, cos(lifetime) * cos(lifetime))
