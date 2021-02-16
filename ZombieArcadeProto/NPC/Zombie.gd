extends KinematicBody2D

onready var ray2d: RayCast2D = $RayCast2D

enum state_enum { Idle, Walking, Chasing }

const TYPE = "ZOMBIE"

var health = 50 setget damage_taken
var speed = 50

var direction = Vector2.ZERO
var objective: Node
var spritedir = "Down"
var state = state_enum.Idle setget change_state


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			pass
		state_enum.Chasing:
			direction = (objective.position - position)
			move_and_slide(direction.normalized()*speed)
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
	if state_enum.keys()[state] == "Chasing":
		$anim.play(str("Walking", spritedir))
	else:
		$anim.play(str(state_enum.keys()[state], spritedir))

func change_state(value: int):
	state = value
	print("Nuevo estado: ", state_enum.keys()[state])



func damage_taken(value):
	health = value
	if health <= 0:
		queue_free()


func _on_vision_body_entered(body):
	if body.TYPE == "PLAYER":
		objective = body
		change_state(state_enum.Chasing)


func _on_vision_body_exited(body):
		if body == objective:
			change_state(state_enum.Idle)
