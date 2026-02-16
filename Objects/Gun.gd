extends 'res://Objects/base_weapon.gd'

const GUNFLASH_SCENE = preload('res://Objects/gunflash.tscn') # Cargar efecto disparo

@onready var ray2d: RayCast2D = $ray2d
@onready var reload_player: AudioStreamPlayer2D = $reload


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
		return
	ammo_loaded -= 1
	# Esta función crea un hijo efecto de disparo
	var gunflash = GUNFLASH_SCENE.instantiate()
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
		if not collider is TileMap and not collider is StaticBody2D and collider.get("TYPE") == "ZOMBIE":
			apply_damage(collider)


func aim():
	# Función bucle para castear el rayo al lugar apuntado
	ray2d.target_position = Vector2.RIGHT * gun_alcance


func picked(body: Node):
	if body.is_aiming:
		return
	$Label.visible = false
	visible = false
	$pickbox/CollisionShape2D.disabled = true
	$PointLight2D.enabled = true
	ray2d.enabled = true
	position = Vector2(8,0)
	body.gun = self
	gun_owner = body
	get_parent().remove_child(self)


func dropped(pos: Vector2):
	$pickbox/CollisionShape2D.disabled = false
	$PointLight2D.enabled = false
	ray2d.enabled = false
	position = pos
