extends 'res://Objects/base_weapon.gd'

const TYPE = "WEAPON"


func _ready():
	damage = 10 # Daño del arma


func shoot():
	$hitbox/CollisionPolygon2D.disabled = false
	$anim.play("Hit")


func aim():
	pass


func die():
	queue_free()


func picked(body: Node):
	if body.is_aiming:
		return
	gun_owner = body
	$Label.visible = false
	$pickbox/CollisionPolygon2D.disabled = true
	position = Vector2(0,0)
	body.gun = self
	get_parent().remove_child(self)


func dropped(pos: Vector2):
	$pickbox/CollisionPolygon2D.disabled = false
	position = pos


func _on_anim_animation_finished(_anim_name):
	$hitbox/CollisionPolygon2D.disabled = true
	# Si no está apuntando, eliminar el nodo
	if not gun_owner.is_aiming:
		queue_free()
	# Cambiar el estado del padre una vez la animación ha terminado
	gun_owner.state = gun_owner.state_enum.Idle


func _on_hitbox_area_entered(area):
	var body = area.get_parent()
	if body == self:
		return
	if body.get("TYPE") == "ZOMBIE":
		body.health = body.health - damage
		# Enviar la dirección del disparo para dirigir el knockback
		body.knockdir = body.position - gun_owner.position


func _on_pickbox_area_exited(_area):
	$Label.visible = false
