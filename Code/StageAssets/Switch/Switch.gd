extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

export var specialFlag := ""

var playerInside := false
var buttonPopup = null
var hasBeenActivated := false
var openFlag: String

signal activated

func _ready():
	openFlag = String(get_path()) + "_open" + specialFlag
	if GlobalData.flags.has(openFlag):
		init_activate()
	Utility.print_connect_errors(get_path(), [
		$EnemyData.connect("on_hit", self, "begin_activate"),
		$AnimationPlayer.connect("animation_finished", self, "anim_completed"),
	])
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_up") && playerInside && !hasBeenActivated:
		begin_activate()

func player_entered(player: Node2D):
	if !hasBeenActivated:
		playerInside = true
		buttonPopup = ButtonPopup.instance()
		buttonPopup.curButton = buttonPopup.Buttons.Up
		player.add_child(buttonPopup)
	
func player_exited(player: Node2D):
	playerInside = false
	if buttonPopup != null:
		player.remove_child(buttonPopup)
		
func anim_completed(anim: String):
	if anim == "TurnOn":
		activate()
		
func begin_activate():
	if !hasBeenActivated:
		$AnimationPlayer.play("TurnOn")

func activate():
	if !hasBeenActivated:
		hasBeenActivated = true
		if buttonPopup != null:
			buttonPopup.queue_free()
			buttonPopup = null
		GlobalData.flags.append(openFlag)
		emit_signal("activated")
		
func init_activate():
	hasBeenActivated = true
	$AnimationPlayer.play("On")
