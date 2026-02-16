extends Node2D

const ZOMBIE_SCENE = preload("res://NPC/Zombie.tscn")
const AMMO_SCENE = preload("res://Objects/Ammo.tscn")
const WALL_TEXTURE = preload("res://Sprites/wall_tile.png")

const TILE_SIZE = 16
const MAP_WIDTH = 64
const MAP_HEIGHT = 40
const INITIAL_ZOMBIES = 5
const INITIAL_AMMO = 8

@onready var player: CharacterBody2D = $Player
@onready var world_floor: Polygon2D = $WorldFloor
@onready var walls_root: Node2D = $Walls
@onready var entities_root: Node2D = $Entities
@onready var timer_label: Label = $CanvasLayer/HUD/VBoxContainer/TimerLabel
@onready var ammo_label: Label = $CanvasLayer/HUD/VBoxContainer/AmmoLabel
@onready var zombie_spawn_timer: Timer = $ZombieSpawnTimer
@onready var ammo_spawn_timer: Timer = $AmmoSpawnTimer

var rng := RandomNumberGenerator.new()
var start_time_msec: int = 0


func _ready() -> void:
	rng.randomize()
	_setup_floor()
	_generate_walls()
	player.global_position = _map_center()
	player.died.connect(_on_player_died)
	start_time_msec = Time.get_ticks_msec()
	for _i in INITIAL_ZOMBIES:
		spawn_zombie()
	for _i in INITIAL_AMMO:
		spawn_ammo()


func _process(_delta: float) -> void:
	var elapsed := float(Time.get_ticks_msec() - start_time_msec) / 1000.0
	var mags_available: int = player.ammo_reserve / player.gun_clip_size
	timer_label.text = "Tiempo: %.1f s" % elapsed
	ammo_label.text = "Balas: %d/%d | Cargadores: %d" % [player.gun_ammo_loaded, player.gun_clip_size, mags_available]


func _setup_floor() -> void:
	var world_size := Vector2(MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE)
	var top_left := Vector2.ZERO
	world_floor.polygon = PackedVector2Array([
		top_left,
		top_left + Vector2(world_size.x, 0),
		top_left + world_size,
		top_left + Vector2(0, world_size.y)
	])


func _generate_walls() -> void:
	for x in MAP_WIDTH:
		_add_wall_cell(Vector2i(x, 0))
		_add_wall_cell(Vector2i(x, MAP_HEIGHT - 1))
	for y in MAP_HEIGHT:
		_add_wall_cell(Vector2i(0, y))
		_add_wall_cell(Vector2i(MAP_WIDTH - 1, y))


func _add_wall_cell(cell: Vector2i) -> void:
	var body := StaticBody2D.new()
	var pos := _cell_to_pos(cell)
	body.global_position = pos

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TILE_SIZE, TILE_SIZE)
	col.shape = shape
	body.add_child(col)

	var sprite := Sprite2D.new()
	sprite.texture = WALL_TEXTURE
	body.add_child(sprite)

	walls_root.add_child(body)


func spawn_zombie() -> void:
	var zombie: CharacterBody2D = ZOMBIE_SCENE.instantiate()
	zombie.global_position = _random_free_point(48.0)
	zombie.set_target(player)
	entities_root.add_child(zombie)


func spawn_ammo() -> void:
	var ammo: Area2D = AMMO_SCENE.instantiate()
	ammo.global_position = _random_free_point(0.0)
	entities_root.add_child(ammo)


func _random_free_point(distance_from_player: float) -> Vector2:
	for _i in 200:
		var p := Vector2(
			rng.randi_range(TILE_SIZE * 2, MAP_WIDTH * TILE_SIZE - TILE_SIZE * 2),
			rng.randi_range(TILE_SIZE * 2, MAP_HEIGHT * TILE_SIZE - TILE_SIZE * 2)
		)
		if distance_from_player > 0.0 and p.distance_to(player.global_position) < distance_from_player:
			continue
		return p
	return _map_center()


func _cell_to_pos(cell: Vector2i) -> Vector2:
	return Vector2(cell * TILE_SIZE) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)


func _map_center() -> Vector2:
	return Vector2(MAP_WIDTH * TILE_SIZE * 0.5, MAP_HEIGHT * TILE_SIZE * 0.5)


func _on_player_died() -> void:
	get_tree().change_scene_to_file("res://World/menu.tscn")


func _on_zombie_spawn_timer_timeout() -> void:
	spawn_zombie()


func _on_ammo_spawn_timer_timeout() -> void:
	spawn_ammo()
