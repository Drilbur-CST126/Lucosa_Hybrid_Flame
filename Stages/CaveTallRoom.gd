	extends "res://Code/CameraScale.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var cameraRight := $Toxen.position.x as float > -160
var cameraCenter := false
var cameraChange := false
var upperRegion := false

func set_player_position():
	var lastRoom := GlobalData.lastRoom
	if lastRoom == "CaveLowerHallway":
		$Toxen.position.x = -635
		$Toxen.position.y = 118
		$DynamicCamera.position = $Toxen.position
		$Toxen.look_right()
	#self.set_previous_screen()
	print(name)

func _ready():
	$DynamicCamera.connect("camera_lock_changed", self, "_camera_lock_changed")
	set_player_position()

func _camera_lock_changed(_lock):
	#print("camera lock changed")
	if cameraCenter:
		cameraCenter = false
		cameraChange = true
		#print("uncentered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(_delta):
#	var pos := $DynamicCamera.position as Vector2
#	if (cameraRight && pos.x < -160) || (!cameraRight && pos.x > -160) || (upperRegion && pos.x > -160.1):
#		$DynamicCamera.position.x = -160.0
#		$DynamicCamera.set_cur_lock($DynamicCamera.Lock.Unlocked)
#		cameraCenter = true
#		cameraChange = false
#		upperRegion = false
##		$DynamicCamera.dynamicLimitUp = -360
##		$DynamicCamera.dynamicLimitDown = 180
#		#print("recentered")
#
##	if !cameraCenter && cameraChange:
##		if $DynamicCamera.position.y >= 89:
##			$DynamicCamera.dynamicLimitUp = 0
##			cameraChange = false
#
#	if cameraCenter && $Toxen.position.y < 89.0:
#		$DynamicCamera.dynamicLimitLeft = -320.0
#		$DynamicCamera.dynamicLimitRight = 0.0
#	if cameraChange && pos.y < -240.0:
#		$DynamicCamera.dynamicLimitLeft = -640.0
#		$DynamicCamera.dynamicLimitRight = 0.0
#		upperRegion = true
#	if cameraChange && $Toxen.position.y >= 40.0:
#		$DynamicCamera.dynamicLimitLeft = -640.0
#		$DynamicCamera.dynamicLimitRight = 320.0
#		upperRegion = false
#
#	if !upperRegion:
#		var divide := 0.0
#		if pos.x == -160.0:
#			divide = -360.0
#		else:
#			divide = -abs(128.0 / (160.0 + pos.x))
#			if divide < -360.0:
#				divide = -360.0
#		$DynamicCamera.dynamicLimitUp = divide
#		$DynamicCamera.dynamicLimitDown = 180.0
#	else:
#		var divide := 0.0
#		if pos.x == -160.0:
#			divide = 180.0
#		else:
#			divide = abs(128.0 / (160.0 + pos.x)) - 180.0
#			if divide > 180.0:
#				divide = 180.0
#		$DynamicCamera.dynamicLimitUp = -360.0
#		$DynamicCamera.dynamicLimitDown = divide
#
#	cameraRight = pos.x > -160
