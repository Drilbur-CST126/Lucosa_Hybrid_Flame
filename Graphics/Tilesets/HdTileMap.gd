tool
extends TileMap

func set_cell(x: int, y: int, tile: int, flip_x:=false, flip_y:=false, transpose:=false, autotile_coord:=Vector2( 0, 0 )):
	if tile == 1 && autotile_coord == tile_set.autotile_get_icon_coordinate(tile) && get_cell(x, y) != -1:
		.set_cell(x, y, 0, flip_x, flip_y, transpose, Vector2(-1, -1))
		update_bitmask_area(Vector2(x, y))
	else:
		.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
