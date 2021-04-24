extends Control

onready var sfxSlider: HSlider = $VBoxContainer/SfxSlider
onready var musicSlider: HSlider = $VBoxContainer/MusicSlider
onready var fullscreenCheckBox: CheckBox = $VBoxContainer/FullscreenCheckBox
onready var acceptButton: Button = $AcceptClose/Accept
onready var closeButton: Button = $AcceptClose/Close

signal on_close()

func _ready():
	sfxSlider.value = int(GlobalData.sfxVolume * 100)
	musicSlider.value = int(GlobalData.musicVolume * 100)
	fullscreenCheckBox.pressed = OS.window_fullscreen
	Utility.print_errors([
		acceptButton.connect("button_down", self, "accept"),
		closeButton.connect("button_down", self, "close"),
	])
	sfxSlider.grab_focus()
	
func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		close()
	
func accept():
	GlobalData.sfxVolume = sfxSlider.value / 100.0
	GlobalData.musicVolume = musicSlider.value / 100.0
	OS.window_fullscreen = fullscreenCheckBox.pressed
	close()
	
func close():
	emit_signal("on_close")
	queue_free()
