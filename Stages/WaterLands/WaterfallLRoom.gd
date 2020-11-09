extends Node2D

enum Position {
	Lower,
	Right,
	Upper,
}

var pos = Position.Lower setget set_pos

func set_pos(val):
	pos = val
	update_camera()
	
func entered(node: Node2D, val):
	if node.get_class() == GlobalData.kPlayerClassName:
		set_pos(val)

func update_camera():
	if pos == Position.Upper:
		$DynamicCamera.dynamicLimitDown = 0
		$DynamicCamera.dynamicLimitLeft = -320
		$DynamicCamera.dynamicLimitRight = 0
		$DynamicCamera.dynamicLimitUp = -180
	elif pos == Position.Lower:
		$DynamicCamera.dynamicLimitDown = 180
		$DynamicCamera.dynamicLimitLeft = -320
		$DynamicCamera.dynamicLimitRight = 320
		$DynamicCamera.dynamicLimitUp = 0
	else:
		$DynamicCamera.dynamicLimitDown = 180
		$DynamicCamera.dynamicLimitLeft = 0
		$DynamicCamera.dynamicLimitRight = 320
		$DynamicCamera.dynamicLimitUp = -180

func _ready():
	Utility.print_connect_errors(get_path(), [
		$CameraAreas/LowerArea2D.connect("body_entered", self, "entered", [Position.Lower]),
		$CameraAreas/RightArea2D.connect("body_entered", self, "entered", [Position.Right]),
		$CameraAreas/UpperArea2D.connect("body_entered", self, "entered", [Position.Upper]),
	])
