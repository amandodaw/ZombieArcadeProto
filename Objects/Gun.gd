extends Sprite

onready var gunflash_scene = load('res://Objects/gunflash.tscn') # Cargar efecto disparo

onready var ray2d = $ray2d
onready var reload_player = $reload

var damage = 10 # Daño del arma
var gun_alcance = 16 * 10 #Alcance del arma / Tile * numero de tiles
var ammo_loaded = 0
const ammo_max = 7
signal finished

onready var gun_owner = get_parent().get_parent() # El nodo entidad padre del arma


func shoot():
	if ammo_loaded == 0:
		$dryshot.play()
		gun_owner.state = gun_owner.state_enum.Idle
		print("HE LLEGADO AQUI :", gun_owner.state)
		return
	ammo_loaded -= 1
	# Esta función crea un hijo efecto de disparo
	var gunflash = gunflash_scene.instance()
	add_child(gunflash)
	# Después reproduce la animación según el lado
	$gunshot.play()
	if flip_v:
		$anim.play("ShootLeft")
	else:
		$anim.play("ShootRight")
	# Si el disparo ha acertado:
	if ray2d.is_colliding():
		var collider = ray2d.get_collider()
		# Y es del tipo zombie 
		if not collider is TileMap and not collider is StaticBody2D and collider.TYPE == "ZOMBIE":
			# Hacer el daño según la variable del arma equipada
			collider.health = collider.health - damage
			# Enviar la dirección del disparo para dirigir el knockback
			collider.knockdir = collider.position - ray2d.get_collision_point()


func raycast_cast():
	# Función bucle para castear el rayo al lugar apuntado
	ray2d.cast_to = Vector2.RIGHT*gun_alcance


func die():
	queue_free()


func _on_anim_animation_finished(anim_name):
	# Si no está apuntando, eliminar el nodo
	if not gun_owner.is_aiming:
		queue_free()
	# Cambiar el estado del padre una vez la animación ha terminado
	gun_owner.state = gun_owner.state_enum.Idle


func _on_pickbox_body_entered(body):
	if not body is TileMap and not body is StaticBody2D:
		if body.TYPE == "PLAYER":
			$pickbox/CollisionShape2D.disabled = true
			$Light2D.enabled = true
			ray2d.enabled = true
			position = Vector2(8,0)
			body.gun = duplicate()
			queue_free()
