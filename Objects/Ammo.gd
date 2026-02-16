extends Sprite2D


const TYPE = "AMMO"


func _on_pickbox_body_entered(body):
	if not body is TileMap and not body is StaticBody2D:
		if body.get("TYPE") == "PLAYER":
			body.ammo_packs += 1
			queue_free()
