extends CharacterBody2D

const BLOOD_SCENE = preload('res://Objects/blood.tscn') # Cargar particula sangre (¿Debería ser aquí?)
const AMMO_SCENE = preload('res://Objects/Ammo.tscn')

enum state_enum { Idle, Walking, Chasing, Knocked } # Enum de los distintos estados

@onready var knockback_timer: Timer = $knockback_timer
@onready var growl_1: AudioStreamPlayer2D = $growl_1
@onready var vision: Area2D = $vision

const TYPE = "ZOMBIE"

var _health: int = 50
var health: int:
	get:
		return _health
	set(value):
		damage_taken(value)

var speed = 25 # Velocidad de movimiento
var knockback_speed = 200 # Velocidad de movimiento al recibir daño
var damage = 20 # Daño del zombie

var direction = Vector2.ZERO # Vector de dirección de movimiento
var knockdir = Vector2.ZERO # Vector de dirección al recibir daño
var objective: Node2D # Nodo objetivo (Jugador o NPC)
var spritedir = "Down" # Dirección del sprite de animación
var _state: int = state_enum.Idle
var state: int:
	get:
		return _state
	set(value):
		change_state(value)


func _physics_process(_delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			pass
		state_enum.Chasing:
			if objective == null or not is_instance_valid(objective):
				change_state(state_enum.Idle)
			else:
				direction = objective.position - position
				velocity = direction.normalized() * speed
				move_and_slide()
		state_enum.Knocked:
			knockback()
	anim_dir()


func anim_dir():
	# Función para reconocer la dirección de movimiento/apuntado y reproducir animación
	
	# Sacamos el angulo del vector de dirección. angle() devuelve rad, y los convertimos
	# de nuevo a grados.
	var dir_angle = rad_to_deg(direction.angle())
	var rounded_angle = int(round(dir_angle/45)*45)
	match rounded_angle:
		0:
			spritedir = "Right"
		-45, -90, -135:
			spritedir = "Up"
		180, -180:
			spritedir = "Left"
		135, 90, 45:
			spritedir = "Down"

	if state_enum.keys()[state] == "Chasing":
		$anim.play(str("Walking", spritedir))
	else:
		$anim.play(str(state_enum.keys()[state], spritedir))


func change_state(value: int):
	_state = value



func damage_taken(value):
	# Función llamada al recibir daño. Spawnear particulas, activar knockback
	# Crear partícula de sangre 
	var blood = BLOOD_SCENE.instantiate()
	add_child(blood)
	knockback_timer.wait_time = float((_health - value))/100
	knockback_timer.start()
	change_state(state_enum.Knocked)
	_health = value
	if _health <= 0:
		queue_free()


func knockback():
	velocity = knockdir.normalized() * knockback_speed
	move_and_slide()


func _on_vision_body_entered(body):
	# Si el objeto del area de visión es el jugador
	if body.get("TYPE") == "PLAYER":
		growl_1.play()
		objective = body
		change_state(state_enum.Chasing)


func _on_vision_body_exited(_body):
	# Si el jugador sale del area. Desactivado de momento
	#	if body == objective:
	#		change_state(state_enum.Idle)
	pass


func _on_knockdown_timer_timeout():
	change_state(state_enum.Idle)
	# Si el jugador está en el area. Inútil? Opinión 1: Sí.
	for body in vision.get_overlapping_bodies():
		if body.get("TYPE") == "PLAYER":
			objective = body
			change_state(state_enum.Chasing)
			break


func _on_hitbox_body_entered(body):
	# Función para inflingir daño si el jugador entra en el hitbox
	if not body is TileMap and not body is StaticBody2D and body.get("TYPE") == "PLAYER":
		body.health -= damage
		body.knockdir = body.position - position


func _on_Zombie_tree_exiting():
	var ammo_pack = AMMO_SCENE.instantiate()
	ammo_pack.global_position = global_position
	var parent_node := get_parent()
	if parent_node != null and is_instance_valid(parent_node):
		parent_node.call_deferred("add_child", ammo_pack)
