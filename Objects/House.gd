extends StaticBody2D


func _ready():
	pass


func _on_area_body_entered(body):
	if not body is TileMap and not body is StaticBody2D:
		if body.get("TYPE") == "PLAYER":
			$Sprite2.visible = false


func _on_area_body_exited(body):
	if not body is TileMap and not body is StaticBody2D:
		if body.get("TYPE") == "PLAYER":
			$Sprite2.visible = true
