extends Light2D

onready var flash_scene = load('res://flash.tscn')


func _ready():
	if get_parent().flip_v:
		position.y += 4
	$Timer.start()
	spawn_flash()


func _on_Timer_timeout():
	queue_free()


func spawn_flash():
	var flash = flash_scene.instance()
	flash.position = position
	get_parent().add_child(flash)

