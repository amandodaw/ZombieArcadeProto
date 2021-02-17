extends KinematicBody2D

onready var gun_scene = load('res://Objects/Gun.tscn')
var gun: Sprite

onready var aim_line: Line2D = $aim_line
onready var ray2d: RayCast2D = $RayCast2D
onready var knockback_timer: Timer = $knockback_timer

enum state_enum { Idle, Walking, Aiming, Knocked }

const TYPE = "PLAYER"

var health = 50 setget damage_taken
var speed = 100
var knockback_speed = 200
var direction = Vector2.ZERO
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
		state_enum.Aiming:
			raycast_control()
		state_enum.Knocked:
			knockback()

func control():
	direction.x = int(Input.is_action_pressed("derecha")) - int(Input.is_action_pressed("izquierda"))
	direction.y = int(Input.is_action_pressed("abajo")) - int(Input.is_action_pressed("arriba"))
	anim_dir()


func move_control():
	control()
	
	if direction == Vector2.ZERO:
		state = state_enum.Idle
		return
	state = state_enum.Walking
	move_and_slide(direction.normalized() * speed)


func aim():
	change_state(state_enum.Aiming)
	gun = gun_scene.instance()
	raycast_control()
	add_child(gun)
	connect("change_aim", gun, "change_aim")
	connect("stop_aim", gun, "die")


func shoot():
	if ray2d.is_colliding():
		var collider = ray2d.get_collider()
		if collider.TYPE == "ZOMBIE":
			collider.health = collider.health - gun.damage
			collider.knockdir = collider.position - ray2d.get_collision_point()
			print(collider.position,ray2d.get_collision_point())
	aim_line.clear_points()
	ray2d.cast_to = Vector2.ZERO
	change_state(state_enum.Idle)
	emit_signal("stop_aim")


func raycast_control():
	control()
	if direction == Vector2.ZERO:
		match spritedir:
			"Left":
				direction = Vector2.LEFT * gun_alcance
			"Right":
				direction = Vector2.RIGHT * gun_alcance
			"Up":
				direction = Vector2.UP * gun_alcance
			"Down":
				direction = Vector2.DOWN * gun_alcance

	ray2d.cast_to = direction.normalized()*gun_alcance - gun.position
	emit_signal("change_aim", direction, spritedir)
	ray2d.position = gun.position
	draw_aim()


func draw_aim():
	if aim_line.get_point_count() == 0:
		aim_line.add_point(gun.position)
		aim_line.add_point(direction.normalized()*gun_alcance)
	else:
		aim_line.clear_points()
		aim_line.add_point(gun.position)
		aim_line.add_point(direction.normalized()*gun_alcance)

func anim_dir():
	match direction:
		Vector2.RIGHT:
			spritedir = "Right"
		Vector2.LEFT:
			spritedir = "Left"
		Vector2.DOWN:
			spritedir = "Down"
		Vector2.UP:
			spritedir = "Up"
	#Linea provisional
	if state_enum.keys()[state] == "Aiming":
		$anim.play(str("Idle", spritedir))
	else:
		$anim.play(str(state_enum.keys()[state], spritedir))


func change_state(value: int):
	state = value
	print("Nuevo estado: ", state_enum.keys()[state])


func damage_taken(value):
	knockback_timer.wait_time = float((health - value))/100
	print("wait time:", knockback_timer.wait_time)
	knockback_timer.start()
	change_state(state_enum.Knocked)
	health = value
	if health <= 0:
		queue_free()


func knockback():
	move_and_slide(knockdir.normalized() * knockback_speed)


func _on_knockback_timer_timeout():
	change_state(state_enum.Idle)
