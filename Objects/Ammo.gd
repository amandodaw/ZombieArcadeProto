extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_pickbox_body_entered(body):
	if not body is TileMap and not body is StaticBody2D:
		if body.TYPE == "PLAYER":
			body.ammo_packs += 1
			queue_free()
