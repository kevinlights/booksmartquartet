extends Spatial

func _ready():
	$CanvasLayer/center/Panel/fullscreen.pressed = Game.fullscreen
	$CanvasLayer/center/Panel/enable_shadows.pressed = Game.shadows

func _on_Back_pressed():
	get_tree().change_scene("res://Menus/MainMenu.tscn")


func _on_fullscreen_toggled(button_pressed):
	Game.set_fullscreen(button_pressed)
	$toggle.play()


func _on_enable_shadows_toggled(button_pressed):
	Game.shadows = button_pressed
	$toggle.play()

func _on_button_hover():
	$hover.play()
