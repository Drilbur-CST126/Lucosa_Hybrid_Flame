extends Node2D

const kNumRooms := 60
var curRoom: Node2D

func get_room_by_id(id: int) -> Node2D:
	return ($Room if id == 1 else get_node_or_null("Room" + String(id))) as Node2D
	
func _ready():
	for i in range(1, kNumRooms + 1):
		var room := get_room_by_id(i)
		if room != null && !Utility.contains(GlobalData.roomsVisited, i):
			room.visible = false
	curRoom = get_room_by_id(GlobalData.curRoom)
			
func _process(delta):
	curRoom.process_glow(delta)
