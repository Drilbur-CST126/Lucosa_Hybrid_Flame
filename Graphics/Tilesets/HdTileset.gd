tool
extends TileSet

enum Ids {
	Normal = 0,
	Water = 1,
	NormalBranch = 2,
	WaterBranch = 3,
}

const binds := {
	Ids.Normal : [Ids.Water, Ids.NormalBranch],
	Ids.Water : [Ids.Normal, Ids.WaterBranch],
}

func _is_tile_bound(drawn_id, neighbor_id):
	if binds.has(drawn_id):
		return binds[drawn_id].has(neighbor_id)
	return false

func is_tile_bound(drawn_id, neighbor_id):
	if binds.has(drawn_id):
		return drawn_id == neighbor_id || binds[drawn_id].has(neighbor_id)
	return false
