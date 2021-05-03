extends Control

const Options = preload("res://Menu/Options.tscn")

var skipAnim := false
var optionsOpen := false

func _ready():
	Utility.print_errors([
		$Background/Options/Quit.connect("button_up", self, "quit"),
		$Background/Options/Options.connect("button_down", self, "open_options"),
		$Background/Options/Resume.connect("button_down", self, "resume"),
		$MapRect/Button.connect("button_down", self, "load_map"),
	])
	$Background/Options/Resume.grab_focus()
	get_tree().paused = true
	if skipAnim:
		$AnimationPlayer.stop()
		modulate = Color.white
		
	$Background/Abilities/Dive.visible = GlobalData.hasDive
	$Background/Abilities/Uppercut.visible = GlobalData.hasUppercut
	$Background/Abilities/Fireball.visible = GlobalData.hasFireball
	$Background/Abilities/DoubleJump.visible = GlobalData.hasDoubleJump
	$Background/Abilities/ExplosionImmunity.visible = GlobalData.hasExplosionImmunity
	$Background/Abilities/TransformAnywhere.visible = GlobalData.canTransformAnywhere
	
	$Background/Upgrades/LifeRings/Label.text = "x" + String(GlobalData.playerMaxHp - GlobalData.kPlayerStartingMaxHp)
	$Background/Upgrades/Runes/Label.text = "x" + String(GlobalData.maxCharges)
	$Background/Upgrades/PowerOrbs/Label.text = "x" + String(GlobalData.playerForesight)
	
func _process(_delta):
	if !optionsOpen:
		if Input.is_action_just_pressed("menu"):
			resume()
		if Input.is_action_just_pressed("second_attack"):
			load_map()
		
func load_map():
	var mapMenu := load("res://Menu/MapMenu.tscn")
	get_parent().add_child(mapMenu.instance())
	queue_free()
	
func open_options():
	var options = Options.instance()
	Utility.print_errors([
		options.connect("on_close", self, "close_options"),
	])
	optionsOpen = true
	$Background.add_child(options)
	
func close_options():
	optionsOpen = false
	$Background/Options/Options.grab_focus()
	
func quit():
	get_tree().paused = false
	Utility.print_errors([
		get_tree().change_scene("res://Menu/MainMenu.tscn")
	])

func resume():
	get_tree().paused = false
	#$AnimationPlayer.play("Close")
	$Background/Options/Quit.disabled = true
	$Background/Options/Options.disabled = true
	$Background/Options/Resume.disabled = true
	#yield($AnimationPlayer, "animation_finished")
	queue_free()
