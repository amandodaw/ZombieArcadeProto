extends KinematicBody2D

onready var gunflash_scene = load('res://Objects/gunflash.tscn')
onready var gun_scene = load('res://Objects/Gun.tscn')
onready var blood_scene = load('res://Objects/blood.tscn')
var gun: Sprite

onready var gun_controller: Node2D = $Gun_controller
onready var aim_line: Line2D = $aim_line
onready var ray2d: RayCast2D = $RayCast2D
onready var knockback_timer: Timer = $knockback_timer
onready var pum: AudioStreamPlayer2D = $pum

enum state_enum { Idle, Walking, Knocked, Shooting }

var is_aiming: bool = false

const TYPE = "PLAYER"

var health = 50 setget damage_taken
var speed = 100
var aim_speed = 2
var knockback_speed = 200
var direction = Vector2.ZERO
var aim_dir = Vector2.ZERO
var knockdir = Vector2.ZERO
var spritedir = "Down"
var state = state_enum.Idle setget change_state
var time_survived = 0

signal stop_aim
signal shoot
#Variables que serán cambiadas porque son propiedades que pertenecen a nodos que aún no existen
var gun_alcance = 16 * 10


func _input(event):
	if event.is_action_pressed("apuntar"):
		if is_aiming:
			stop_aim()
		else:
			start_aim()
	if event.is_action_pressed("disparar"):
		if is_aiming:
			shoot()

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			move_control()
			if is_aiming:
				aim()
		state_enum.Knocked:
			knockback()
		state_enum.Shooting:
			anim_dir()

func control():
	direction.x = int(Input.is_action_pressed("derecha")) - int(Input.is_action_pressed("izquierda"))
	direction.y = int(Input.is_action_pressed("abajo")) - int(Input.is_action_pressed("arriba"))
	anim_dir()


func aim_control():
	aim_dir = Vector2(Input.get_joy_axis ( 0,JOY_AXIS_2 ), Input.get_joy_axis ( 0,JOY_AXIS_3 ))


func move_control():
	control()
	if direction == Vector2.ZERO:
		change_state(state_enum.Idle)
		return
	change_state(state_enum.Walking)
	move_and_slide(direction.normalized() * speed)


func start_aim():
	speed = speed/aim_speed
	is_aiming = true
	gun = gun_scene.instance()
	gun_controller.add_child(gun)
	connect("stop_aim", gun, "die")
	connect("shoot", gun, "shoot")


func aim():
	#aim_control()
	aim_dir = get_global_mouse_position() - global_position
	gun_controller.rotation = aim_dir.angle()
	if abs(gun_controller.rotation) >= PI/2:
		gun.flip_v = true
	else:
		gun.flip_v = false
	raycast_cast()


func stop_aim():
	if state == state_enum.Shooting:
		return
	is_aiming = false
	speed = speed*aim_speed
	gun_controller.remove_child(gun)
	aim_line.clear_points()


func shoot():
	emit_signal("shoot")
	change_state(state_enum.Shooting)
	var gunflash = gunflash_scene.instance()
	gun.add_child(gunflash)
	if ray2d.is_colliding():
		var collider = ray2d.get_collider()
		if not collider is TileMap and collider.TYPE == "ZOMBIE":
			var blood = blood_scene.instance()
			collider.add_child(blood)
			collider.health = collider.health - gun.damage
			collider.knockdir = collider.position - ray2d.get_collision_point()
			


func raycast_cast():
	ray2d.cast_to = aim_dir.normalized()*gun_alcance - gun.position
	ray2d.position = gun.position
	draw_aim(aim_dir)



func draw_aim(cast_to: Vector2):
	if aim_line.get_point_count() == 0:
		aim_line.add_point(gun_controller.position)
		aim_line.add_point(cast_to.normalized()*gun_alcance)
	else:
		aim_line.clear_points()
		aim_line.add_point(gun_controller.position)
		aim_line.add_point(cast_to.normalized()*gun_alcance)

func anim_dir():
	var to: Vector2
	if is_aiming:
		to = aim_dir
	else:
		to = direction
	var dir_angle = rad2deg(to.angle())
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
		
	#Linea provisional
	if state == state_enum.Shooting:
		$anim.play(str("Idle", spritedir))
	else:
		$anim.play(str(state_enum.keys()[state], spritedir))



func change_state(value: int):
	state = value
	print(state_enum.keys()[state])
	#print("Nuevo estado: ", state_enum.keys()[state])


func damage_taken(value):
	knockback_timer.wait_time = float((health - value))/100
	knockback_timer.start()
	change_state(state_enum.Knocked)
	health = value
	if health <= 0:
		get_parent().game_over()
		queue_free()


func knockback():
	move_and_slide(knockdir.normalized() * knockback_speed)


func _on_knockback_timer_timeout():
	change_state(state_enum.Idle)


func _on_Timer_timeout():
	time_survived += 1
	$Label.text = str("Segundos \nsobrevividos: ",time_survived)
