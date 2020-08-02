extends "res://Code/CameraScale.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var pos := $Toxen.position as Vector2
	var dyn := $DynamicCamera
	
	if (pos.y <= 0):
		dyn.dynamicLimitDown = 0
	elif (pos.x > -320):
		dyn.dynamicLimitDown = (960.0 - pos.x) * 180.0 / 1280.0
	else:
		dyn.dynamicLimitDown = 180
		
	dyn.dynamicLimitUp = dyn.dynamicLimitDown - dyn.height
