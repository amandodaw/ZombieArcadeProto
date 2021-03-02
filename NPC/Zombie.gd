extends KinematicBody2D

onready var blood_scene = load('res://Objects/blood.tscn') # Cargar particula sangre (¿Debería ser aquí?)
onready var ammo_scene = load('res://Objects/Ammo.tscn')

enum state_enum { Idle, Walking, Chasing, Knocked } # Enum de los distintos estados

onready var knockback_timer = $knockback_timer 
onready var growl_1 = $growl_1

const TYPE = "ZOMBIE"

var health = 50 setget damage_taken # Puntos de vida
var speed = 25 # Velocidad de movimiento
var knockback_speed = 200 # Velocidad de movimiento al recibir daño
var damage = 20 # Daño del zombie

var direction = Vector2.ZERO # Vector de dirección de movimiento
var knockdir = Vector2.ZERO # Vector de dirección al recibir daño
var objective: Node # Nodo objetivo (Jugador o NPC)
var spritedir = "Down" # Dirección del sprite de animación
var state = state_enum.Idle setget change_state # Estado por defecto Idle


# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			pass
		state_enum.Chasing:
			direction = (objective.position - position)
			move_and_slide(direction.normalized()*speed)
		state_enum.Knocked:
			knockback()
	anim_dir()


func anim_dir():
	# Función para reconocer la dirección de movimiento/apuntado y reproducir animación
	
	# Sacamos el angulo del vector de dirección. angle() devuelve rad, y los convertimos
	# de nuevo a grados.
	var dir_angle = rad2deg(direction.angle())
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
	state = value
	print("Nuevo estado: ", state_enum.keys()[state])



func damage_taken(value):
	# Función llamada al recibir daño. Spawnear particulas, activar knockback
	# Crear partícula de sangre 
	var blood = blood_scene.instance()
	add_child(blood)
	knockback_timer.wait_time = float((health - value))/100
	print("wait time:", knockback_timer.wait_time)
	knockback_timer.start()
	change_state(state_enum.Knocked)
	health = value
	if health <= 0:
		queue_free()


func knockback():
	move_and_slide(knockdir.normalized() * knockback_speed)


func _on_vision_body_entered(body):
	# Si el objeto del area de visión es el jugador
	if body.TYPE == "PLAYER":
		growl_1.play()
		objective = body
		change_state(state_enum.Chasing)


func _on_vision_body_exited(body):
	# Si el jugador sale del area. Desactivado de momento
	#	if body == objective:
	#		change_state(state_enum.Idle)
	pass


func _on_knockdown_timer_timeout():
	change_state(state_enum.Idle)
	# Si el jugador está en el area. Inútil? Opinión 1: Sí.
	for body in $vision.get_overlapping_bodies():
		if body.TYPE == "PLAYER":
			objective = body
			change_state(state_enum.Chasing)
			break


func _on_hitbox_body_entered(body):
	# Función para inflingir daño si el jugador entra en el hitbox
	print("si", body.get_name())
	if not body is TileMap and not body is StaticBody2D and body.TYPE == "PLAYER":
		body.health -= damage
		body.knockdir = body.position - position


func _on_Zombie_tree_exiting():
	var ammo_pack = ammo_scene.instance()
	ammo_pack.global_position = global_position
	get_parent().add_child(ammo_pack)
