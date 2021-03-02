extends TileMap

onready var ocluder_poly_scene = load('res://World/wall_ocluder.tscn')


func add_occluders():
	for tile in get_used_cells_by_id(0):
		var ocupoly = ocluder_poly_scene.instance()
		ocupoly.position = map_to_world(tile)
		add_child(ocupoly)
		print("Hecho ", ocupoly)

