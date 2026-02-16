extends StaticBody2D


const TYPE = "DOOR"

func _ready():
	pass


func change_frame():
	if $Sprite.frame == 0:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0

func _on_Sprite_frame_changed():
	if $Sprite.frame == 0:
		$CollisionShape2D.disabled = false
		$CollisionShape2D2.disabled = true
	else:
		$CollisionShape2D2.disabled = false
		$CollisionShape2D.disabled = true
