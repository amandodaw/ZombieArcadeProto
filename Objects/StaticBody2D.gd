extends StaticBody2D


const TYPE = "DOOR"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
