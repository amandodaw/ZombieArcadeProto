extends Control

func _ready():
	set_focus_order()


func _on_Button_pressed():
	get_tree().change_scene_to_file('res://World/World.tscn')
	queue_free()


func _on_Button2_pressed():
	get_tree().quit()

func set_focus_order():
	$MarginContainer/VBoxContainer/Button.grab_focus()
