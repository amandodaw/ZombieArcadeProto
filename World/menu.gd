extends Control
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	setFocusOrder()

#func _input(event):
#	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().change_scene('res://World/World.tscn')
	queue_free()


func _on_Button2_pressed():
	get_tree().quit()

func setFocusOrder():
	$MarginContainer/VBoxContainer/Button.grab_focus()
