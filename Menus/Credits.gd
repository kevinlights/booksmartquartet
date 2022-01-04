extends Spatial

func _on_Back_pressed():
	get_tree().change_scene("res://Menus/MainMenu.tscn")


func _on_fullscreen_toggled(button_pressed):
	Game.set_fullscreen(button_pressed)
