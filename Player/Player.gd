extends CharacterBody2D

const BLOOD_SCENE = preload('res://Objects/blood.tscn') # Cargar particula sangre (¿Debería ser aquí?)

var gun: Sprite2D # Preparar variable (futura arma recogida)

@onready var gun_controller: Node2D = $Gun_controller # Nodo de referencia rotacion arma
@onready var aim_line: Line2D = $aim_line # Línea de apuntado (¿Sustituír por sprite?)
@onready var knockback_timer: Timer = $knockback_timer # Cronómetro duración knockback
@onready var reload_timer: Timer = $reload_timer
@onready var hitbox: Area2D = $hitbox
@onready var anim_player: AnimationPlayer = $anim

enum state_enum { Idle, Walking, Knocked, Shooting, Reloading } # Enum de los distintos estados

var is_aiming: bool = false 
var is_stopping_aim: bool = false # Necesaria para cuando el personaje está disparando y quiere dejar de hacerlo al mismo tiempo

const TYPE = "PLAYER" # Tipo de entidad

var _health: int = 50
var health: int:
	get:
		return _health
	set(value):
		damage_taken(value)

var speed = 100 # Velocidad de movimiento
var aim_speed = 2 # Velocidad al apuntar (speed será dividida por aim_speed)
var knockback_speed = 200 # Velocidad de movimiento al recibir daño
var direction = Vector2.ZERO # Vector de dirección de movimiento
var aim_dir = Vector2.ZERO # Vector de dirección de apuntar
var knockdir = Vector2.ZERO # Vector de dirección al recibir daño
var spritedir = "Down" # Dirección del sprite de animación
var _state: int = state_enum.Idle
var state: int:
	get:
		return _state
	set(value):
		change_state(value)
var ammo_packs = 0
var time_survived = 0 


signal stop_aim_signal # Para indicar al arma que sea destruida
signal shoot_signal # Para indicar al arma que reproduzca su animación

#Variables auxiliares de noob



func _input(event: InputEvent):
	if event.is_action_pressed("apuntar"):
		if is_aiming:
			stop_aim()
		else:
			start_aim()
	if event.is_action_pressed("disparar"):
		if is_aiming:
			shoot()
	if event.is_action_pressed("recargar"):
		reload()
	if event.is_action_released("recargar"):
		if state == state_enum.Reloading:
			if not reload_timer.is_stopped():
				reload_timer.stop()
			state = state_enum.Idle
	if event.is_action_pressed("ui_select"):
		for body in hitbox.get_overlapping_bodies():
			if not body is TileMap and body.get("TYPE") == "DOOR":
				body.change_frame()
	if event.is_action_pressed("accion"):
		if is_aiming and gun != null:
			stop_aim()
			drop_weapon()
		for area in hitbox.get_overlapping_areas():
			var body = area.get_parent()
			if body.get("TYPE") == "WEAPON":
				if !is_aiming and gun != null:
					drop_weapon()
				body.picked(self)


func _physics_process(_delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			move_control()
			if is_aiming:
				aim()
		state_enum.Knocked:
			knockback()
		state_enum.Shooting, state_enum.Reloading:
			aim()
			anim_dir()
			#control()
			#move_and_slide(direction.normalized() * speed)


func control():
	# Función para traducir el input a movimiento
	direction.x = int(Input.is_action_pressed("derecha")) - int(Input.is_action_pressed("izquierda"))
	direction.y = int(Input.is_action_pressed("abajo")) - int(Input.is_action_pressed("arriba"))
	anim_dir()


func aim_control():
	# Para apuntar con joystick derecho
	aim_dir = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))


func move_control():
	# Función a llamar para mover al personaje
	control()
	# Si la dirección es parar, estado Idle y salir de la función.
	if direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		change_state(state_enum.Idle)
		return
	change_state(state_enum.Walking)
	velocity = direction.normalized() * speed
	move_and_slide()


func start_aim():
	# Función para comenzar a apuntar, cambiar variables y crear escena pistola hija
	if gun == null:
		print("No llevas un arma encima")
		return
	speed = speed/aim_speed
	is_aiming = true
	gun.visible = true
	gun_controller.add_child(gun)
	stop_aim_signal.connect(Callable(gun, "die"))
	shoot_signal.connect(Callable(gun, "shoot"))


func aim():
	# Función bucle para recoger input del mouse y apuntar en esa dirección
	#aim_control()
	aim_dir = get_global_mouse_position() - global_position
	# Rotar el nodo padre del arma según el ángulo del vector resultante 
	gun_controller.rotation = aim_dir.angle()
	# Cambiar la posición del arma de izquierda a derecha según su ángulo
	if abs(gun_controller.rotation) >= PI/2:
		gun.flip_v = true
	else:
		gun.flip_v = false
	gun.aim()


func stop_aim():
	# Función a llamar para finalizar el modo apuntado. Cambio de variables y destrucción
	# de hijos
	# Comprobar si el jugador ha intentado dejar de apuntar mientras disparaba y almacenar su intención
	if state == state_enum.Shooting:
		is_stopping_aim = true
		return
	is_stopping_aim = false
	is_aiming = false
	speed = speed*aim_speed
	gun_controller.remove_child(gun)
	aim_line.clear_points()


func shoot():
	# Función a llamar para ejecutar un disparo
	# Evitar la ejecución si ya se está disparando
	if state == state_enum.Shooting:
		return
	change_state(state_enum.Shooting)
	shoot_signal.emit() # Esto provocará que la pistola reproduzca la animación


func reload():
	if is_aiming and ammo_packs > 0:
		reload_timer.start()
		state = state_enum.Reloading
		gun.reload_player.play()
	else:
		print("No tienes arma/munición")


func drop_weapon():
	gun.dropped(position)
	get_parent().add_child(gun)	
	var stop_aim_callable := Callable(gun, "die")
	if stop_aim_signal.is_connected(stop_aim_callable):
		stop_aim_signal.disconnect(stop_aim_callable)
	var shoot_callable := Callable(gun, "shoot")
	if shoot_signal.is_connected(shoot_callable):
		shoot_signal.disconnect(shoot_callable)
	gun = null

func draw_aim(cast_to: Vector2):
	# Función bucle para dibujar la línea de apuntado 
	if aim_line.get_point_count() == 0:
		aim_line.add_point(gun_controller.position)
		aim_line.add_point(cast_to.normalized()*gun.gun_alcance)
	else:
		aim_line.set_point_position(0, gun_controller.position)
		aim_line.set_point_position(1, cast_to.normalized()*gun.gun_alcance)


func anim_dir():
	# Función para reconocer la dirección de movimiento/apuntado y reproducir animación
	var to: Vector2
	#Si is_aiming es true, se escogerá el vector de apuntar en vez de el de movimiento
	if is_aiming:
		to = aim_dir
	else:
		# Para evitar que cuando no se este moviendo piense que el angulo es 0:
		if direction == Vector2.ZERO:
			anim_player.play(str(state_enum.keys()[state], spritedir))
			return
		to = direction
	# Sacamos el angulo del vector de dirección. angle() devuelve rad, y los convertimos
	# de nuevo a grados.
	var dir_angle = rad_to_deg(to.angle())
	var rounded_angle = int(round(dir_angle/45)*45)
	# Según el angulo, indicamos una dirección a la animación
	match rounded_angle:
		0:
			spritedir = "Right"
		-45, -90, -135:
			spritedir = "Up"
		180, -180:
			spritedir = "Left"
		135, 90, 45:
			spritedir = "Down"
	# Reproducimos la animación
	if state == state_enum.Shooting or state == state_enum.Reloading:
		anim_player.play(str("Idle", spritedir))
	else:
		anim_player.play(str(state_enum.keys()[state], spritedir))


func change_state(value: int):
	# Setter del estado
	_state = value
	if is_stopping_aim:
		stop_aim()
	#print("Nuevo estado: ", state_enum.keys()[state])


func damage_taken(value):
	# Función llamada al recibir daño (setter)
	# Crear partícula de sangre 
	var blood = BLOOD_SCENE.instantiate()
	add_child(blood)
	# Comenzar estado noqueo
	knockback_timer.wait_time = float((_health - value))/100
	knockback_timer.start()
	change_state(state_enum.Knocked)
	# Restamos el daño y llamamos a la función game_over si la vida es 0
	_health = value
	if _health <= 0:
		get_parent().game_over()
		queue_free()


func knockback():
	velocity = knockdir.normalized() * knockback_speed
	move_and_slide()


func _on_knockback_timer_timeout():
	change_state(state_enum.Idle)


func _on_reload_timer_timeout():
	gun.ammo_loaded = 7
	ammo_packs -= 1
	change_state(state_enum.Idle)
