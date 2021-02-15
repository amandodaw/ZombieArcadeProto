extends KinematicBody2D

onready var gun_scene = load('res://Objects/Gun.tscn')

onready var ray2d: RayCast2D = $RayCast2D

enum state_enum { Idle, Walking, Aiming }

var speed = 100
var direction = Vector2.ZERO
var spritedir = "Down"
var state = state_enum.Idle setget change_state


#Variables que serán cambiadas porque son propiedades que pertenecen a nodos que aún no existen
var gun_alcance = 16 * 10


func _input(event):
	if event.is_action_pressed("disparar"):
		change_state(state_enum.Aiming)
	elif event.is_action_released("disparar"):
		ray2d.cast_to = Vector2.ZERO
		change_state(state_enum.Idle)


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			move_control()
		state_enum.Aiming:
			aim_control()

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


func aim_control():
	var gun = gun_scene.instance()
	add_child(gun)
	gun.position = direction
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
		return
	ray2d.cast_to = direction.normalized()*gun_alcance

	

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
