extends TileMap

const OCLUDER_POLY_SCENE = preload('res://World/wall_ocluder.tscn')


func add_occluders():
	for tile in get_used_cells(0):
		var ocupoly = OCLUDER_POLY_SCENE.instantiate()
		ocupoly.position = map_to_local(tile)
		add_child(ocupoly)
