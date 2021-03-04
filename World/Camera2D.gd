extends Camera2D

onready var player = get_node('../Player')


func _physics_process(_delta):
	if player == null:
		return
	position = player.position
