extends Control

var skipAnim := false

func _ready():
	Utility.print_errors([
		$Background/Options/Quit.connect("button_up", self, "quit"),
		$Background/Options/Options.connect("button_up", self, "options"),
		$Background/Options/Resume.connect("button_up", self, "resume"),
		$MapRect/Button.connect("button_down", self, "load_map"),
	])
	$Background/Options/Resume.grab_focus()
	get_tree().paused = true
	if skipAnim:
		$AnimationPlayer.stop()
		modulate = Color.white
	
func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		resume()
	if Input.is_action_just_pressed("second_attack"):
		load_map()
		
func load_map():
	var mapMenu := load("res://Menu/MapMenu.tscn")
	get_parent().add_child(mapMenu.instance())
	queue_free()
	
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
