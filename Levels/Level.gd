extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if event.is_action_pressed("forward"):
		$Cursor.translation.z += 2
	elif event.is_action_pressed("back"):
		$Cursor.translation.z -= 2
	elif event.is_action_pressed("left"):
		$Cursor.translation.x += 2
	elif event.is_action_pressed("right"):
		$Cursor.translation.x -= 2
	elif event.is_action_pressed("pause"):
		get_tree().paused = true
		$CanvasLayer/center/menu_buttons.show()

func _on_resume_pressed():
	get_tree().paused = false
	$CanvasLayer/center/menu_buttons.hide()


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menus/MainMenu.tscn")
