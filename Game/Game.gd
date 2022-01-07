extends Node

var player_class = "Rogue"
var player_name = "Player"

var book_types = [ 
	"Red Book",
	"Green Book",
	"Brown Book",
	"Blue Book"
]
var dont_interrupt = [ "cheer", "attack", "defeat" ]
var dont_walk = [ "defeat" ]
# settings

var shadows = false
var fullscreen = false

func set_fullscreen(toggle):
	fullscreen = toggle
	OS.window_fullscreen = toggle
