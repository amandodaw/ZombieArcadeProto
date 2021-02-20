extends Sprite

var damage = 10
signal finished

onready var gun_owner = get_parent().get_parent()

func shoot():
	$gunshot.play()
	if flip_v:
		$anim.play("ShootLeft")
	else:
		$anim.play("ShootRight")

func die():
	queue_free()

func _on_anim_animation_finished(anim_name):
	if not gun_owner.is_aiming:
		queue_free()
	gun_owner.state = gun_owner.state_enum.Idle
