#tool
extends Camera2D
class_name DynamicCamera

enum Lock {CtrLeft, CtrRight, LeftTrans, RightTrans, Unlocked}
enum Adjust {Default, Up, Down}

const kAdjustAmount := 64.0

var width := ProjectSettings.get_setting("display/window/size/width") as int
var height := ProjectSettings.get_setting("display/window/size/height") as int

export var lockOffset := 24.0
export var snapOffset := 48.0
export var snapSpeed := 256.0
export var yCenter := 0.0
export var target: NodePath

export var dynamicLimitLeft := -100000
export var dynamicLimitRight := 100000
export var dynamicLimitUp := -100000
export var dynamicLimitDown := 100000

var curLock = Lock.CtrLeft
var shakeSeverity := 0.0
var shaking := false
var canAdjust := true
var adjust = Adjust.Default


signal camera_lock_changed(lock)
signal shaking_finished()


func get_class():
	return "DynamicCamera"
	
func force_camera_to_pos():
	force_update_scroll()
	force_update_transform()
	reset_smoothing()
	
func shake(severity: float, duration: float):
	shakeSeverity = severity
	shaking = true
	if duration > 0:
		yield(Utility.create_timer(self,duration), "timeout")
		shaking = false
		emit_signal("shaking_finished")
		offset = Vector2.ZERO
	
func position_at_spawn_point():
	var spawnFound := false
	for node in get_parent().get_children():
		if node.get_class() == "RoomSpawnPoint" && node.is_current_spawn():
			position = node.position
			spawnFound = true
	if !spawnFound:
		position = get_target_pos()
		
	set_camera_in_limits()

func _ready():
	width = int(width * zoom.x)
	height = int(height * zoom.y)
	GlobalData.camera = self
	GlobalData.oldCameraLimits = null
	position_at_spawn_point()
	
	# Auto-set limits
	if limit_left == -10000000 && get_parent().has_node("StageBg"):
		var bg := get_parent().get_node("StageBg") as ColorRect
		limit_left = int(bg.margin_left)
		limit_right = int(bg.margin_right)
		limit_top = int(bg.margin_top)
		limit_bottom = int(bg.margin_bottom)
	if dynamicLimitLeft == -100000:
		dynamicLimitUp = limit_top
		dynamicLimitDown = limit_bottom
		dynamicLimitLeft = limit_left
		dynamicLimitRight = limit_right

func set_cur_lock(value):
	curLock = value
	emit_signal("camera_lock_changed", curLock)

func get_target_pos() -> Vector2:
	if get_node_or_null(target) == null:
		return Vector2(position.x, position.y)
	return get_node(target).position
	
func set_camera_in_limits(offset := 0.0):
	if position.x + width / 2.0 > dynamicLimitRight:
		position.x = dynamicLimitRight - width / 2.0
	if position.x - width / 2.0 < dynamicLimitLeft:
		position.x = dynamicLimitLeft + width / 2.0
	if position.y + height / 2.0 > dynamicLimitDown:
		position.y = dynamicLimitDown - height / 2.0
	if position.y - height / 2.0 < dynamicLimitUp:
		position.y = dynamicLimitUp + height / 2.0
		
	if offset != 0.0:
		position.y += offset
		set_camera_in_limits()

func _physics_process(delta):
	var targetPos = get_target_pos()
	
	var yOffset := 0.0
	if !get_tree().paused:
		match adjust:
			Adjust.Default:
				if Input.is_action_pressed("ui_up"):
					adjust = Adjust.Up
					$CameraAdjustTimer.start()
				elif Input.is_action_pressed("ui_down"):
					adjust = Adjust.Down
					$CameraAdjustTimer.start()
			Adjust.Up:
				if Input.is_action_just_released("ui_up"):
					adjust = Adjust.Default
					$CameraAdjustTimer.stop()
				elif $CameraAdjustTimer.time_left == 0.0:
					yOffset -= kAdjustAmount
			Adjust.Down:
				if Input.is_action_just_released("ui_down"):
					adjust = Adjust.Default
					$CameraAdjustTimer.stop()
				elif $CameraAdjustTimer.time_left == 0.0:
					yOffset += kAdjustAmount
					
	if !Engine.editor_hint:
		if curLock == Lock.CtrLeft:
			if targetPos.x - lockOffset <= position.x:
				position.x = targetPos.x - lockOffset
		elif curLock == Lock.CtrRight:
			if targetPos.x + lockOffset >= position.x:
				position.x = targetPos.x + lockOffset
				
		if targetPos.x - snapOffset >= position.x:
			curLock = Lock.RightTrans 
			emit_signal("camera_lock_changed", curLock)
		if targetPos.x + snapOffset <= position.x:
			curLock = Lock.LeftTrans
			emit_signal("camera_lock_changed", curLock)
		
		if curLock == Lock.RightTrans:
			position.x += snapSpeed * delta
			if position.x >= targetPos.x + lockOffset:
				position.x = targetPos.x + lockOffset
				curLock = Lock.CtrRight
				
		if curLock == Lock.LeftTrans:
			position.x -= snapSpeed * delta
			if position.x <= targetPos.x - lockOffset:
				position.x = targetPos.x - lockOffset
				curLock = Lock.CtrLeft
		
		position.y = targetPos.y - yCenter
		
		set_camera_in_limits(yOffset)
		
	if shaking:
		offset = Vector2(GlobalData.random.randf_range(-shakeSeverity, shakeSeverity), \
				GlobalData.random.randf_range(-shakeSeverity, shakeSeverity))
				
	if !Engine.editor_hint && !smoothing_enabled:
		#print("RESET")
		smoothing_enabled = true
		force_camera_to_pos()
