extends KinematicBody2D

onready var ray2d: RayCast2D = $RayCast2D

enum state_enum { Idle, Walking }

var speed = 100
var direction = Vector2.ZERO
var spritedir = "Down"
var state = state_enum.Idle setget change_state


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	anim_dir()


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
	$anim.play(str(state_enum.keys()[state], spritedir))


func change_state(value: int):
	state = value
	print("Nuevo estado: ", state_enum.keys()[state])
