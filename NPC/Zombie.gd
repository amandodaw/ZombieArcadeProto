extends KinematicBody2D

enum state_enum { Idle, Walking, Chasing, Knocked }

onready var knockback_timer = $knockback_timer
onready var growl_1 = $growl_1

const TYPE = "ZOMBIE"

var health = 50 setget damage_taken
var speed = 25
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
	var dir_angle = rad2deg(direction.angle())
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
		growl_1.play()
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
