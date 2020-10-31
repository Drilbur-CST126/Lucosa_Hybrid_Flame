extends "res://Code/PlayerArea.gd"

const ButtonPopup = preload("res://Code/ButtonPopup.tscn")

var playerInside := false
var buttonPopup

# Called when the node enters the scene tree for the first time.
#func _ready():
#	Utility.print_connect_errors(get_path(),[
#		connect("body_entered", self, "entered"),
#		connect("body_exited", self, "exited")
#	])

#func entered(node: Node2D):
#	if node.get_class() == GlobalData.kPlayerClassName:
#		playerInside = true
		
func player_entered(player: Node2D):
	playerInside = true
	buttonPopup = ButtonPopup.instance()
	buttonPopup.curButton = buttonPopup.Buttons.Up
	player.add_child(buttonPopup)
	
#func exited(node: Node2D):
#	if node.get_class() == GlobalData.kPlayerClassName:
#		playerInside = false
		
func player_exited(player: Node2D):
	playerInside = false
	player.remove_child(buttonPopup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if playerInside && Input.is_action_just_pressed("ui_up"):
		GlobalData.playerHp = GlobalData.playerMaxHp
		GlobalData.save(get_parent().filename)
