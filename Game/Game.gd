extends Node

var player_class = "Rogue"
var player_name = "Player"

var book_types = [ 
	"Red Book",
	"Green Book",
	"Brown Book",
	"Blue Book"
]

# settings

var shadows = false
var fullscreen = false

func set_fullscreen(toggle):
	fullscreen = toggle
	OS.window_fullscreen = toggle
