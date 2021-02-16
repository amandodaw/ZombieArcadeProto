extends KinematicBody2D

onready var gun_scene = load('res://Objects/Gun.tscn')
var gun: Sprite

onready var ray2d: RayCast2D = $RayCast2D

enum state_enum { Idle, Walking, Aiming }

const TYPE = "PLAYER"

var speed = 100
var direction = Vector2.ZERO
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
		ray2d.cast_to = Vector2.ZERO
		change_state(state_enum.Idle)
		emit_signal("stop_aim")
		if ray2d.is_colliding():
			var collider = ray2d.get_collider()
			if collider.TYPE == "ZOMBIE":
				collider.health = collider.health - gun.damage


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			move_control()
		state_enum.Aiming:
			raycast_control()

func control():
	direction.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	direction.y = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
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


func raycast_control():
	control()
	if direction == Vector2.ZERO:
		match spritedir:
			"Left":
				ray2d.cast_to = Vector2.LEFT * gun_alcance
			"Right":
				ray2d.cast_to = Vector2.RIGHT * gun_alcance
			"Up":
				ray2d.cast_to = Vector2.UP * gun_alcance
			"Down":
				ray2d.cast_to = Vector2.DOWN * gun_alcance
	else:
		ray2d.cast_to = direction.normalized()*gun_alcance
	emit_signal("change_aim", direction, spritedir)

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
