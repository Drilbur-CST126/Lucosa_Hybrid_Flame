extends ColorRect

const kMapScrollSpeed := 1024.0

var map: Node2D
	
func get_current_room_center() -> Vector2:
	var curRoomId := GlobalData.curRoom
	var curRoom = map.get_room_by_id(curRoomId)
	return (curRoom.get_center() as Vector2) * map.scale

func _ready():
	map = $Background/Map
	map.position = $Background.rect_size / 2.0 - get_current_room_center()
	
func _process(delta: float):
	if Input.is_action_just_pressed("menu"):
		resume()
	if Input.is_action_just_pressed("second_attack"):
		load_menu()
		
	var moveAmount := kMapScrollSpeed * delta
	var offset := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		offset.y += moveAmount
	if Input.is_action_pressed("ui_down"):
		offset.y -= moveAmount
	if Input.is_action_pressed("ui_left"):
		offset.x += moveAmount
	if Input.is_action_pressed("ui_right"):
		offset.x -= moveAmount
	map.position += offset
		
func resume():
	get_tree().paused = false
	queue_free()

func load_menu():
	var pauseMenu = load("res://Menu/PauseMenu.tscn").instance()
	pauseMenu.skipAnim = true
	get_parent().add_child(pauseMenu)
	queue_free()
