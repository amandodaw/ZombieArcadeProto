extends Sprite

signal finished


onready var gun_owner = get_parent().get_parent()


var damage: int

func shoot():
	pass


func damage(body: Node):
	body.health = body.health - damage
	# Enviar la dirección del disparo para dirigir el knockback
	body.knockdir = body.position - gun_owner.position


func aim():
	pass


func die():
	queue_free()


func picked(body: Node):
	pass


func _on_anim_animation_finished(anim_name):
	print(gun_owner)
	# Si no está apuntando, eliminar el nodo
	if not gun_owner.is_aiming:
		queue_free()
	# Cambiar el estado del padre una vez la animación ha terminado
	gun_owner.state = gun_owner.state_enum.Idle


func _on_pickbox_area_entered(area):
	var body = area.get_parent()
	if body == self:
		return
	if body.TYPE == "PLAYER":
		$Label.visible = true
		picked(body)


func _on_hitbox_area_entered(area):
	var body = area.get_parent()
	if body == self:
		return
	if body.TYPE == "ZOMBIE":
		damage(body)


func _on_pickbox_area_exited(area):
	$Label.visible = false
