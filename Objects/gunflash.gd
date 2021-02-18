extends Light2D

onready var flash_scene = load('res://flash.tscn')


func _ready():
	#rotation_degrees = get_parent().gun.rotation_degrees
	change_aim()	
	$Timer.start()
	spawn_flash()


func _on_Timer_timeout():
	queue_free()


func spawn_flash():
	var flash = flash_scene.instance()
	flash.position = position
	get_parent().add_child(flash)



func change_aim():
	var direction = get_parent().direction
	var spritedir = get_parent().spritedir
	match spritedir:
		"Right":
			z_index = 0
			position = Vector2.RIGHT*16
			rotation_degrees = 0
		"Left":
			z_index = -1
			position = Vector2.LEFT*16
			rotation_degrees = -180
		"Up":
			z_index = -1
			position = Vector2.UP*16
			rotation_degrees = -90
		"Down":
			z_index = 0
			position = Vector2.DOWN*16
			rotation_degrees = 90
	match direction:
		Vector2.RIGHT:
			rotation_degrees = 0
		Vector2.LEFT:
			rotation_degrees = -180
		Vector2.UP:
			rotation_degrees = -90
		Vector2.DOWN:
			rotation_degrees = 90
		Vector2(1, 1):
			match spritedir:
				"Right":
					rotation_degrees = 45
					position.y += 8
				"Down":
					rotation_degrees = 45
					position.x += 8
		Vector2(-1, -1):
			match spritedir:
				"Left":
					rotation_degrees = 235
					position.y -= 8
				"Up":
					rotation_degrees = 235
					position.x -= 8
		Vector2(-1, 1):
			match spritedir:
				"Left":
					rotation_degrees = 135
					position.y += 8
				"Down":
					rotation_degrees = 135
					position.x -= 8
		Vector2(1, -1):
			match spritedir:
				"Right":
					rotation_degrees = -45
					position.y -= 8
				"Up":
					rotation_degrees = -45
					position.x += 8
