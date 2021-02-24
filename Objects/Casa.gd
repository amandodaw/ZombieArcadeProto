extends StaticBody2D




func _on_roof_area_body_entered(body):
	if not body is TileMap and not body is StaticBody2D and body.TYPE == "PLAYER":
		$tejado.visible = false


func _on_roof_area_body_exited(body):
	if not body is TileMap and not body is StaticBody2D and body.TYPE == "PLAYER":
		$tejado.visible = true
