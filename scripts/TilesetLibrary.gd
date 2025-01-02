extends Resource

static func get_direction_vector(tile_map_layer: TileMapLayer, coords:Vector2i) -> Vector2:
	#gets the direction the tile is facing
	#don't ask me how this code works, i didn't write it
	
	var vec = Vector2.RIGHT
	
	var alt = tile_map_layer.get_cell_alternative_tile(coords)
	
	if alt & TileSetAtlasSource.TRANSFORM_TRANSPOSE:
		vec = Vector2(vec.y, vec.x)
	if alt & TileSetAtlasSource.TRANSFORM_FLIP_H:
		vec.x *= -1
	if alt & TileSetAtlasSource.TRANSFORM_FLIP_V:
		vec.y *= -1

	return Vector2(vec.y, vec.x)

static func direction_vec_to_rotation(direction_vec: Vector2, inDegrees = false) -> float:
	var output
	match direction_vec:
		Vector2.DOWN:
			output = 0
		Vector2.RIGHT:
			output = PI/2
		Vector2.UP:
			output = PI
		Vector2.LEFT:
			output = 3 * PI/2
	if inDegrees:
		return rad_to_deg(output)
	else:
		return output
			
			
		
