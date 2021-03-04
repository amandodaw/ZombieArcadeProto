extends 'res://Objects/base_weapon.gd'

onready var gunflash_scene = load('res://Objects/gunflash.tscn') # Cargar efecto disparo

onready var ray2d = $ray2d
onready var reload_player = $reload


const TYPE = "WEAPON"


var gun_alcance = 16 * 10 #Alcance del arma / Tile * numero de tiles
var ammo_loaded: int
const ammo_max = 7


func _ready():
	damage = 10 # Daño del arma


func shoot():
	if ammo_loaded == 0 :
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
			damage(collider)


func aim():
	print(ammo_loaded)
	# Función bucle para castear el rayo al lugar apuntado
	ray2d.cast_to = Vector2.RIGHT*gun_alcance


func picked(body: Node):
	if body.is_aiming:
		return
	$Label.visible = false
	$pickbox/CollisionShape2D.disabled = true
	$Light2D.enabled = true
	ray2d.enabled = true
	position = Vector2(8,0)
	body.gun = duplicate()
	queue_free()


func dropped(pos: Vector2):
	$pickbox/CollisionShape2D.disabled = false
	$Light2D.enabled = false
	ray2d.enabled = false
	position = pos
