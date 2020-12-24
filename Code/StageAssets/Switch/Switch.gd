extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

var playerInside := false
var buttonPopup = null

signal activated

func _ready():
	Utility.print_connect_errors(get_path(), [
		$EnemyData.connect("on_hit", self, "activate"),
	])
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_up") && playerInside:
		activate()

func player_entered(player: Node2D):
	playerInside = true
	buttonPopup = ButtonPopup.instance()
	buttonPopup.curButton = buttonPopup.Buttons.Up
	player.add_child(buttonPopup)
	
func player_exited(player: Node2D):
	playerInside = false
	player.remove_child(buttonPopup)

func activate():
	$Circle.color = Color.green
	emit_signal("activated")
