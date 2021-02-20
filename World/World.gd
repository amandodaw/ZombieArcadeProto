extends Node2D

onready var menu_scene = load('res://World/menu.tscn')
onready var zombie_scene = load('res://NPC/Zombie.tscn')

onready var tilemap: TileMap = $TileMap

onready var player:= $Player

onready var map_size = OS.window_size/tilemap.cell_size/2
onready var half_cell_size  = tilemap.cell_size/tilemap.cell_size * 2

var rng:= RandomNumberGenerator.new()


var zombie_number = 1
var zombie_max_number = 3

func _ready():
	print(map_size)
	rng.randomize()
	generate_border()
	generate_inner()


func generate_border():
	for x in [0, map_size.x]:
		for y in range(map_size.y+1):
			tilemap.set_cell(x, y, 1)
	for y in [0, map_size.y]:
		for x in range(map_size.x):
			tilemap.set_cell(x, y, 1)


func generate_inner():
	for x in range(1, map_size.x):
		for y in range(1, map_size.y):
			tilemap.set_cell(x, y, 0)


func spawn_zombies():
	for i in zombie_number:
		var zombie = zombie_scene.instance()
		var rand_pos  = Vector2(rng.randi_range(1,map_size.x-1), rng.randi_range(1,map_size.y-1))
		zombie.position = tilemap.map_to_world(rand_pos)
		add_child(zombie)
	if zombie_number < zombie_max_number:
		zombie_number += 1
	else:
		zombie_number = 0

func game_over():
	get_tree().change_scene('res://World/menu.tscn')
	queue_free()


func _on_zombieSpawn_timer_timeout():
	spawn_zombies()
