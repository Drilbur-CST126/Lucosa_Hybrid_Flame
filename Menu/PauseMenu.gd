extends Control

func _ready():
	Utility.print_errors([
		$Background/Options/Quit.connect("button_up", self, "quit"),
		$Background/Options/Options.connect("button_up", self, "options"),
		$Background/Options/Resume.connect("button_up", self, "resume"),
	])
	$Background/Options/Resume.grab_focus()
	get_tree().paused = true
	
func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		resume()
	
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
