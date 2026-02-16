extends CharacterBody2D

const TYPE = "ZOMBIE"

@export var speed := 52.0
@export var max_health := 60
@export var touch_damage := 12
@export var attack_interval := 0.8

@onready var sprite: Sprite2D = $Sprite2D
@onready var growl_sfx: AudioStreamPlayer2D = $GrowlSfx

var target: Node2D
var health: int
var attack_cooldown := 0.0
var facing: String = "Down"
var anim_clock: float = 0.0


func _ready() -> void:
	add_to_group("zombie")
	health = max_health
	if randf() > 0.55:
		growl_sfx.play()


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := target.global_position - global_position
	if dir.length() > 2.0:
		velocity = dir.normalized() * speed
		if absf(dir.x) > absf(dir.y):
			facing = "Right" if dir.x > 0.0 else "Left"
		else:
			facing = "Down" if dir.y > 0.0 else "Up"
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	_update_sprite(delta, dir.length() > 2.0)
	attack_cooldown = max(0.0, attack_cooldown - delta)
	if dir.length() < 16.0 and attack_cooldown <= 0.0:
		if target.has_method("take_damage"):
			target.take_damage(touch_damage)
		attack_cooldown = attack_interval


func _update_sprite(delta: float, moving: bool) -> void:
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
	anim_clock += delta
	if moving:
		var w_frames: Array = walk_frames.get(facing, [0])
		sprite.frame = w_frames[int(anim_clock / 0.1) % w_frames.size()]
	else:
		var i_frames: Array = idle_frames.get(facing, [0])
		sprite.frame = i_frames[int(anim_clock / 0.3) % i_frames.size()]


func set_target(value: Node2D) -> void:
	target = value


func take_damage(amount: int) -> void:
	health -= amount
	if health > 0:
		return
	queue_free()
