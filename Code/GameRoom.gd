extends Node2D
class_name GameRoom

export var mapId := 1

func _ready():
	if !Utility.contains(GlobalData.roomsVisited, mapId):
		GlobalData.roomsVisited.append(mapId)
		
	GlobalData.curRoom = mapId
