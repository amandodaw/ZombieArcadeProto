extends GPUParticles2D

func _ready():
	var mat: ParticleProcessMaterial = process_material
	if mat != null:
		mat.direction = Vector3(randi() % 3 - 1, randi() % 3 - 1, 0)


func _on_Timer_timeout():
	queue_free()
