extends Control

func _ready():
	set_focus_order()


func _on_Button_pressed():
	get_tree().change_scene_to_file('res://World/World.tscn')
	queue_free()


func _on_Button2_pressed():
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_Button2_pressed()

func set_focus_order():
	var retry: Button = $CenterContainer/Panel/Margin/VBox/Buttons/ButtonRetry
	var quit: Button = $CenterContainer/Panel/Margin/VBox/Buttons/ButtonQuit
	retry.focus_neighbor_bottom = retry.get_path_to(quit)
	quit.focus_neighbor_top = quit.get_path_to(retry)
	retry.focus_neighbor_right = retry.get_path_to(quit)
	quit.focus_neighbor_left = quit.get_path_to(retry)
	retry.grab_focus()
