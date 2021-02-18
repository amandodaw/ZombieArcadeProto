extends KinematicBody2D

onready var gunflash_scene = load('res://Objects/gunflash.tscn')
onready var gun_scene = load('res://Objects/Gun.tscn')
var gun: Sprite

onready var aim_line: Line2D = $aim_line
onready var ray2d: RayCast2D = $RayCast2D
onready var knockback_timer: Timer = $knockback_timer
onready var pum: AudioStreamPlayer2D = $pum

enum state_enum { Idle, Walking, Knocked }

var is_aiming: bool = false

const TYPE = "PLAYER"

var health = 50 setget damage_taken
var speed = 100
var aim_speed = 2
var knockback_speed = 200
var direction = Vector2.ZERO
var aim_direction = Vector2.ZERO
var knockdir = Vector2.ZERO
var spritedir = "Down"
var state = state_enum.Idle setget change_state

signal change_aim
signal stop_aim
#Variables que serán cambiadas porque son propiedades que pertenecen a nodos que aún no existen
var gun_alcance = 16 * 10


func _input(event):
	if event.is_action_pressed("disparar"):
		aim()
	elif event.is_action_released("disparar"):
		shoot()


# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			move_control()
			if is_aiming:
				raycast_control()

		state_enum.Knocked:
			knockback()

func control():
	direction.x = int(Input.is_action_pressed("derecha")) - int(Input.is_action_pressed("izquierda"))
	direction.y = int(Input.is_action_pressed("abajo")) - int(Input.is_action_pressed("arriba"))
	anim_dir()


func aim_control():
	aim_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	aim_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	anim_dir()


func move_control():
	control()
	if direction == Vector2.ZERO:
		change_state(state_enum.Idle)
		return
	change_state(state_enum.Walking)
	move_and_slide(direction.normalized() * speed)


func aim():
	is_aiming = true
	speed = speed/aim_speed
	gun = gun_scene.instance()
	raycast_control()
	add_child(gun)
	connect("change_aim", gun, "change_aim")
	connect("stop_aim", gun, "die")


func shoot():
	if ray2d.is_colliding():
		pum.play()
		var collider = ray2d.get_collider()
		if collider.TYPE == "ZOMBIE":
			collider.health = collider.health - gun.damage
			collider.knockdir = collider.position - ray2d.get_collision_point()
			print(collider.position,ray2d.get_collision_point())
		var gunflash = gunflash_scene.instance()
		add_child(gunflash)
	aim_line.clear_points()
	ray2d.cast_to = Vector2.ZERO
	is_aiming = false
	emit_signal("stop_aim")
	speed = speed*aim_speed

func raycast_control():
	if is_aiming:
		aim_control()
		raycast_cast(aim_direction)
	else:
		control()



func raycast_cast(cast_to: Vector2):
	if cast_to == Vector2.ZERO:
		match spritedir:
			"Left":
				cast_to = Vector2.LEFT * gun_alcance
			"Right":
				cast_to = Vector2.RIGHT * gun_alcance
			"Up":
				cast_to = Vector2.UP * gun_alcance
			"Down":
				cast_to = Vector2.DOWN * gun_alcance
	ray2d.cast_to = cast_to.normalized()*gun_alcance - gun.position
	emit_signal("change_aim", cast_to, spritedir)
	ray2d.position = gun.position
	draw_aim(cast_to)


func draw_aim(cast_to: Vector2):
	if aim_line.get_point_count() == 0:
		aim_line.add_point(gun.position)
		aim_line.add_point(cast_to.normalized()*gun_alcance)
	else:
		aim_line.clear_points()
		aim_line.add_point(gun.position)
		aim_line.add_point(cast_to.normalized()*gun_alcance)

func anim_dir():
	var to: Vector2
	if is_aiming:
		to = aim_direction
	else:
		to = direction
	match to:
		Vector2.RIGHT:
			spritedir = "Right"
		Vector2.LEFT:
			spritedir = "Left"
		Vector2.DOWN:
			spritedir = "Down"
		Vector2.UP:
			spritedir = "Up"
		Vector2(1, 1):
			spritedir = "Down"
		Vector2(-1, -1):
			spritedir = "Up"
		Vector2(-1, 1):
			spritedir = "Down"
		Vector2(1, -1):
			spritedir = "Up"
	#Linea provisional
	$anim.play(str(state_enum.keys()[state], spritedir))


func change_state(value: int):
	state = value
	print("Nuevo estado: ", state_enum.keys()[state])


func damage_taken(value):
	knockback_timer.wait_time = float((health - value))/100
	knockback_timer.start()
	change_state(state_enum.Knocked)
	health = value
	if health <= 0:
		queue_free()


func knockback():
	move_and_slide(knockdir.normalized() * knockback_speed)


func _on_knockback_timer_timeout():
	change_state(state_enum.Idle)
