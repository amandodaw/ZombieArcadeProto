extends CharacterBody2D

const TYPE = "PLAYER"
const GUN_FLASH_SCENE = preload("res://Objects/gunflash.tscn")

@export var move_speed := 125.0
@export var max_health := 100
@export var gun_clip_size := 7
@export var gun_range := 260.0
@export var gun_damage := 35
@export var bat_damage := 45
@export var bat_range := 34.0

@onready var body_sprite: Sprite2D = $BodySprite
@onready var gun_sprite: Sprite2D = $WeaponPivot/GunSprite
@onready var bat_sprite: Sprite2D = $WeaponPivot/BatSprite
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var camera: Camera2D = $Camera2D
@onready var gun_cooldown: Timer = $GunCooldown
@onready var bat_cooldown: Timer = $BatCooldown
@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSfx
@onready var dryshot_sfx: AudioStreamPlayer2D = $DryshotSfx
@onready var reload_sfx: AudioStreamPlayer2D = $ReloadSfx

var health: int
var gun_ammo_loaded: int = 0
var ammo_reserve: int = 0
var facing: String = "Down"
var anim_state: String = ""
var anim_frame_time: float = 0.0

signal died


func _ready() -> void:
	health = max_health
	gun_ammo_loaded = gun_clip_size
	ammo_reserve = gun_clip_size * 3
	bat_sprite.visible = false
	camera.make_current()


func _physics_process(delta: float) -> void:
	var is_moving := _handle_movement()
	_handle_aim()
	_update_body_animation(delta, is_moving)
	if Input.is_action_just_pressed("disparar"):
		shoot()
	if Input.is_action_just_pressed("accion"):
		swing_bat()
	if Input.is_action_just_pressed("recargar"):
		reload_gun()


func _handle_movement() -> bool:
	var input := Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = input * move_speed
	move_and_slide()
	if input.x > 0.1:
		facing = "Right"
	elif input.x < -0.1:
		facing = "Left"
	elif input.y < -0.1:
		facing = "Up"
	elif input.y > 0.1:
		facing = "Down"
	return input.length() > 0.1


func _update_body_animation(delta: float, is_moving: bool) -> void:
	var idle_frames := {
		"Down": [0, 12],
		"Left": [3, 13],
		"Right": [6, 14],
		"Up": [9, 15]
	}
	var walk_frames := {
		"Down": [0, 1, 0, 2],
		"Left": [3, 4, 3, 5],
		"Right": [6, 7, 6, 8],
		"Up": [9, 10, 9, 11]
	}

	var next_state := "Walking" if is_moving else "Idle"
	if next_state != anim_state:
		anim_state = next_state
		anim_frame_time = 0.0

	anim_frame_time += delta
	if anim_state == "Walking":
		var w_frames: Array = walk_frames.get(facing, [0])
		var w_index := int(anim_frame_time / 0.1) % w_frames.size()
		body_sprite.frame = w_frames[w_index]
	else:
		var i_frames: Array = idle_frames.get(facing, [0])
		var i_index := int(anim_frame_time / 0.3) % i_frames.size()
		body_sprite.frame = i_frames[i_index]


func _handle_aim() -> void:
	var dir: Vector2 = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	if dir.length() < 0.2:
		dir = (get_global_mouse_position() - global_position)
	dir = dir.normalized()
	if dir == Vector2.ZERO:
		return
	weapon_pivot.rotation = dir.angle()
	weapon_pivot.scale.y = -1.0 if dir.x < 0.0 else 1.0


func shoot() -> void:
	if not gun_cooldown.is_stopped():
		return
	if gun_ammo_loaded <= 0:
		dryshot_sfx.play()
		return

	gun_ammo_loaded -= 1
	gun_cooldown.start()
	shoot_sfx.play()

	var flash: Node2D = GUN_FLASH_SCENE.instantiate()
	flash.global_position = weapon_pivot.to_global(Vector2(18, 0))
	flash.global_rotation = weapon_pivot.global_rotation
	get_parent().add_child(flash)

	var from: Vector2 = gun_sprite.global_position
	var to: Vector2 = from + Vector2.RIGHT.rotated(weapon_pivot.global_rotation) * gun_range
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider_obj: Variant = hit["collider"]
	if collider_obj is Node and collider_obj.is_in_group("zombie"):
		collider_obj.take_damage(gun_damage)


func swing_bat() -> void:
	if not bat_cooldown.is_stopped():
		return
	bat_cooldown.start()
	bat_sprite.visible = true
	await get_tree().create_timer(0.08).timeout
	bat_sprite.visible = false

	var attack_center: Vector2 = global_position + Vector2.RIGHT.rotated(weapon_pivot.global_rotation) * 22.0
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = bat_range
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, attack_center)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	params.exclude = [self]
	var results: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(params, 12)
	for hit in results:
		var collider_obj: Variant = hit["collider"]
		if collider_obj is Node and collider_obj.is_in_group("zombie"):
			collider_obj.take_damage(bat_damage)


func reload_gun() -> void:
	if gun_ammo_loaded >= gun_clip_size:
		return
	if ammo_reserve <= 0:
		return
	reload_sfx.play()
	var needed: int = gun_clip_size - gun_ammo_loaded
	var transfer: int = mini(needed, ammo_reserve)
	gun_ammo_loaded += transfer
	ammo_reserve -= transfer


func add_ammo(amount: int) -> void:
	ammo_reserve += amount


func take_damage(amount: int) -> void:
	health -= amount
	if health > 0:
		return
	died.emit()
	queue_free()
