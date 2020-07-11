	extends "res://Code/CameraScale.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var cameraRight := $Toxen.position.x as float > -160
var cameraCenter := false
var cameraChange := false

func _ready():
	$DynamicCamera.connect("camera_lock_changed", self, "_camera_lock_changed")

func _camera_lock_changed(lock):
	#print("camera lock changed")
	if cameraCenter:
		cameraCenter = false
		cameraChange = true
		#print("uncentered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var pos := $DynamicCamera.position as Vector2
	if (cameraRight && pos.x < -160) || (!cameraRight && pos.x > -160):
		$DynamicCamera.position.x = -160.0
		$DynamicCamera.set_cur_lock($DynamicCamera.Lock.Unlocked)
		cameraCenter = true
		cameraChange = false
#		$DynamicCamera.dynamicLimitUp = -360
#		$DynamicCamera.dynamicLimitDown = 180
		#print("recentered")
		
#	if !cameraCenter && cameraChange:
#		if $DynamicCamera.position.y >= 89:
#			$DynamicCamera.dynamicLimitUp = 0
#			cameraChange = false

	if cameraCenter:
		if pos.y < 89.0:
			$DynamicCamera.dynamicLimitLeft = -320.0
			$DynamicCamera.dynamicLimitRight = 0.0
	if cameraChange && pos.y >= 40.0:
		$DynamicCamera.dynamicLimitLeft = -640.0
		$DynamicCamera.dynamicLimitRight = 320.0

	var divide := 0.0
	if pos.x == -160.0:
		divide = -320.0
	else:
		divide = -abs(128.0 / (160.0 + pos.x))
		if divide < -320.0:
			divide = -320.0
	$DynamicCamera.dynamicLimitUp = divide
	
	cameraRight = pos.x > -160
