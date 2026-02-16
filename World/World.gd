extends Node2D

const ZOMBIE_SCENE = preload('res://NPC/Zombie.tscn')  #Cargar escena de zombie
const DOOR_SCENE = preload('res://Objects/StaticBody2D.tscn')

@onready var tilemap: TileMap = $TileMap  #Cargar variable TileMap
@onready var tilemap2: TileMap = $TileMap2

var map_size: Vector2i
var half_cell_size: Vector2

var rng := RandomNumberGenerator.new()

var house_size: Vector2i = Vector2i(12, 6)
var zombie_number: int = 1
var zombie_max_number: int = 3


func _ready():
	#setViewCenter()
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	map_size = Vector2i((get_viewport_rect().size / Vector2(tile_size) / 2.0).floor())
	half_cell_size = Vector2(tile_size) / 2.0
	rng.randomize()
	generate_border()
	generate_inner()
	generate_house(Vector2i(5, 5))
	tilemap2.add_occluders()


func generate_border():
	# Genera el borde del mapa usando el tile wall
	for x in [0, map_size.x]:
		for y in range(map_size.y + 1):
			tilemap.set_cell(0, Vector2i(x, y), 1)
	for y in [0, map_size.y]:
		for x in range(map_size.x):
			tilemap.set_cell(0, Vector2i(x, y), 1)


func generate_inner():
	#Genera el interior del mapa usando el tile floor
	for x in range(1, map_size.x):
		for y in range(1, map_size.y):
			tilemap.set_cell(0, Vector2i(x, y), 0)


func generate_house(start: Vector2i):
	var end: Vector2i = start + house_size
	for x in [start.x, end.x]:
		for y in range(start.y, end.y + 1):
			tilemap2.set_cell(0, Vector2i(x, y), 0)
	for y in [start.y, end.y]:
		for x in range(start.x, end.x):
			if y == end.y and x == int((start.x + end.x) / 2):
				var door = DOOR_SCENE.instantiate()
				door.global_position = tilemap.map_to_local(Vector2i(x + 2, y + 2))
				add_child(door)
				continue
			tilemap2.set_cell(0, Vector2i(x, y), 0)


func spawn_zombies():
	#Invocar zombies en un lugar aleatorio del mapa
	for _i in zombie_number:
		var zombie = ZOMBIE_SCENE.instantiate()
		var rand_pos: Vector2i = Vector2i(
			rng.randi_range(1, map_size.x - 1), rng.randi_range(1, map_size.y - 1)
		)
		zombie.position = tilemap.map_to_local(rand_pos) + half_cell_size
		add_child(zombie)
	if zombie_number < zombie_max_number:
		zombie_number += 1
	else:
		zombie_number = 0


func game_over():
	# Llamada cuando el jugador muere
	get_tree().change_scene_to_file('res://World/menu.tscn')
	queue_free()


func setViewCenter():
	# Situa el juego en el centro de la primera pantalla

	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	DisplayServer.window_set_position(screen_size*0.5 - window_size*0.5)


func _on_zombieSpawn_timer_timeout():
	spawn_zombies()
