extends KinematicBody2D

enum state_enum { Idle, Walking, Chasing, Knocked }

onready var knockback_timer = $knockback_timer

const TYPE = "ZOMBIE"

var health = 50 setget damage_taken
var speed = 50
var knockback_speed = 200
var damage = 20

var direction = Vector2.ZERO
var knockdir = Vector2.ZERO
var objective: Node
var spritedir = "Down"
var state = state_enum.Idle setget change_state


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
	if body.TYPE == "PLAYER":
		objective = body
		change_state(state_enum.Chasing)


func _on_vision_body_exited(body):
		if body == objective:
			change_state(state_enum.Idle)


func _on_knockdown_timer_timeout():
	change_state(state_enum.Idle)
	for body in $vision.get_overlapping_bodies():
		if body.TYPE == "PLAYER":
			objective = body
			change_state(state_enum.Chasing)
			break


func _on_hitbox_body_entered(body):
	print("si", body.get_name())
	if not body is TileMap and body.TYPE == "PLAYER":
		body.health -= damage
		body.knockdir = body.position - position
