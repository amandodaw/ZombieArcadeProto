extends Node2D

onready var tilemap: TileMap = $TileMap

onready var player:= $Player

onready var map_size = OS.window_size/tilemap.cell_size/2
onready var half_cell_size  = tilemap.cell_size/tilemap.cell_size * 2

var rng:= RandomNumberGenerator.new()


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
