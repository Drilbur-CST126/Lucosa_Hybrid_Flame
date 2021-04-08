extends PlayerArea
class_name MapArea

export var mapId := 1

func player_entered(_player):
	if !Utility.contains(GlobalData.roomsVisited, mapId):
		GlobalData.roomsVisited.append(mapId)
		
	GlobalData.curRoom = mapId
	
