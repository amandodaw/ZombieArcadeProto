extends Sprite

onready var gunflash_scene = load('res://Objects/gunflash.tscn') # Cargar efecto disparo

var damage = 10 # Daño del arma
var gun_alcance = 16 * 10 #Alcance del arma / Tile * numero de tiles
signal finished

onready var gun_owner = get_parent().get_parent() # El nodo entidad padre del arma


func shoot():
	# Esta función crea un hijo efecto de disparo
	var gunflash = gunflash_scene.instance()
	add_child(gunflash)
	# Después reproduce la animación según el lado
	$gunshot.play()
	if flip_v:
		$anim.play("ShootLeft")
	else:
		$anim.play("ShootRight")

func die():
	queue_free()

func _on_anim_animation_finished(anim_name):
	# Si no está apuntando, eliminar el nodo
	if not gun_owner.is_aiming:
		queue_free()
	# Cambiar el estado del padre una vez la animación ha terminado
	gun_owner.state = gun_owner.state_enum.Idle
