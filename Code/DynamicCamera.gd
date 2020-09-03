tool
extends Camera2D

enum Lock {CtrLeft, CtrRight, LeftTrans, RightTrans, Unlocked}

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

signal camera_lock_changed(lock)

func _ready():
	position = get_target_pos()
	smoothing_enabled = true
	print(position)
	width *= zoom.x
	height *= zoom.y

func set_cur_lock(value):
	curLock = value
	emit_signal("camera_lock_changed", curLock)

func get_target_pos() -> Vector2:
	if get_node_or_null(target) == null:
		return Vector2(position.x, position.y)
	return get_node(target).position

func _physics_process(delta):
	var targetPos = get_target_pos()
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
	
	if position.x + width / 2.0 > dynamicLimitRight:
		position.x = dynamicLimitRight - width / 2.0
	if position.x - width / 2.0 < dynamicLimitLeft:
		position.x = dynamicLimitLeft + width / 2.0
	if position.y + height / 2.0 > dynamicLimitDown:
		position.y = dynamicLimitDown - height / 2.0
	if position.y - height / 2.0 < dynamicLimitUp:
		position.y = dynamicLimitUp + height / 2.0
