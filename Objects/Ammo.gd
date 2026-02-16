extends Area2D

const TYPE = "AMMO"
@export var ammo_amount := 7


func _on_body_entered(body: Node) -> void:
	if body.has_method("add_ammo"):
		body.add_ammo(ammo_amount)
		queue_free()
