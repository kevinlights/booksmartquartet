extends VBoxContainer

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = false
		hide()
