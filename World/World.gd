extends Node2D

onready var menu_scene = load('res://World/menu.tscn')  #Cargar escena de men� 
onready var zombie_scene = load('res://NPC/Zombie.tscn')  #Cargar escena de zombie
onready var door_scene = load('res://Objects/StaticBody2D.tscn')

onready var tilemap: TileMap = $TileMap  #Cargar variable TileMap 
onready var tilemap2: TileMap = $TileMap2

onready var player := $Player  #Cargar variable jugador

# Calculamos el tama�o del mapa dividiendo por el tama�o de un tile
onready var map_size = OS.window_size / tilemap.cell_size / 2
# Y la mitad de esta
onready var half_cell_size = tilemap.cell_size / tilemap.cell_size * 2

var rng := RandomNumberGenerator.new()

var house_size = Vector2(12,6)
var zombie_number = 1  #N�mero de zombies a invocar
var zombie_max_number = 3


func _ready():
	#setViewCenter()
	print(map_size)
	rng.randomize()
	generate_border()
	generate_inner()
	generate_house(Vector2(5,5))
	tilemap2.add_occluders()


func generate_border():
	# Genera el borde del mapa usando el tile wall
	for x in [0, map_size.x]:
		for y in range(map_size.y + 1):
			tilemap.set_cell(x, y, 1)
	for y in [0, map_size.y]:
		for x in range(map_size.x):
			tilemap.set_cell(x, y, 1)


func generate_inner():
	#Genera el interior del mapa usando el tile floor
	for x in range(1, map_size.x):
		for y in range(1, map_size.y):
			tilemap.set_cell(x, y, 0)


func generate_house(start: Vector2):
	var end = start + house_size
	for x in [start.x, end.x]:
		for y in range(start.y, end.y+1):
			tilemap2.set_cell(x, y, 0)
	for y in [start.y, end.y]:
		for x in range(start.x, end.x):
			if y == end.y and x == int((start.x + end.x)/2):
				var door = door_scene.instance()
				door.global_position = tilemap.map_to_world(Vector2(x+2,y+2))
				add_child(door)
				continue
			tilemap2.set_cell(x, y, 0)


func spawn_zombies():
	#Invocar zombies en un lugar aleatorio del mapa
	for i in zombie_number:
		var zombie = zombie_scene.instance()
		var rand_pos = Vector2(
			rng.randi_range(1, map_size.x - 1), rng.randi_range(1, map_size.y - 1)
		)
		zombie.position = tilemap.map_to_world(rand_pos) + half_cell_size
		add_child(zombie)
	if zombie_number < zombie_max_number:
		zombie_number += 1
	else:
		zombie_number = 0


func game_over():
	# Llamada cuando el jugador muere
	get_tree().change_scene('res://World/menu.tscn')
	queue_free()


func setViewCenter():
	# Situa el juego en el centro de la primera pantalla

	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)


func _on_zombieSpawn_timer_timeout():
	spawn_zombies()
