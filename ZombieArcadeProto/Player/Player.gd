extends KinematicBody2D


enum state_enum {Idle, Moving}


var speed = 100
var direction = Vector2.ZERO
var spritedir = "Down"
var state = state_enum.Idle setget change_state

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	move_control()


func move_control():
	direction.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	direction.y = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
	
	if direction == Vector2.ZERO:
		state = state_enum.Idle
		return
	state = state_enum.Moving
	anim_dir()
	move_and_slide(direction.normalized()*speed)



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
	$anim.play(str("Walking", spritedir))

func change_state(value: int):
	state = value
	print("Nuevo estado: ")
