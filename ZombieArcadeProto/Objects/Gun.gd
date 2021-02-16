extends Sprite


var damage = 10


func change_aim(direction, spritedir):
	match spritedir:
		"Right":
			frame = 0
			z_index = 0
			position = Vector2.RIGHT*8
			rotation_degrees = 0
		"Left":
			z_index = -1
			frame = 1
			position = Vector2.LEFT*8
			rotation_degrees = 0
		"Up":
			z_index = -1
			frame = 0
			position = Vector2.UP*8
			rotation_degrees = -90
		"Down":
			frame = 0
			z_index = 0
			position = Vector2.DOWN*8
			rotation_degrees = 90
	match direction:
		Vector2.RIGHT:
			rotation_degrees = 0
		Vector2.LEFT:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = -90
		Vector2.DOWN:
			rotation_degrees = 90
		Vector2(1, 1):
			match spritedir:
				"Right":
					rotation_degrees = 45
				"Down":
					rotation_degrees = 45
		Vector2(-1, -1):
			match spritedir:
				"Left":
					rotation_degrees = 45
				"Up":
					rotation_degrees = 235
		Vector2(-1, 1):
			match spritedir:
				"Left":
					rotation_degrees = -45
				"Down":
					rotation_degrees = 135
		Vector2(1, -1):
			match spritedir:
				"Right":
					rotation_degrees = -45
				"Up":
					rotation_degrees = -45


func die():
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


