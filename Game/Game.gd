extends Node

var player_class = "Rogue"
var player_name = "Player"

# settings

var shadows = false
var fullscreen = false

func set_fullscreen(toggle):
	fullscreen = toggle
	OS.window_fullscreen = toggle
