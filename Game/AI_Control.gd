class_name AI_Player
extends Node

onready var player = get_parent()

var walk_speed = 10
var rotate_speed = 5

var book_types = [ 
	"Red Book",
	"Green Book",
	"Brown Book",
	"Blue Book"
]

var bot_names = [
	"Boten Anna",
	"Skynet",
	"Agent Smith",
	"HAL 9000",
	"GLaDOS",
	"Bender",
	"T-900",
	"Mr Robot",
	"Data",
	"Roboto",
	"Lexx",
	"Andromeda",
	"Borg Drone",
	"R2D2",
	"C3PO",
	"Droideka",
	"Roomba"
]

var want = "Red Book"
var target = null
var home = null
var path = []

func init_bot():
	randomize()
	bot_names.shuffle()
	book_types.shuffle()
	player.player_name = bot_names[0]
	player.get_node("PlayerName").text = player.player_name
	want = book_types[0]
	home = player.translation

func _ready():
	init_bot()
	get_target()
	player.local = false

func _physics_process(delta):
	if target and path.size() > 0:
		var move_vector = -1 * player.translation.direction_to(path[0])
		player.move_and_slide (-1 * walk_speed * move_vector, Vector3(0, 1, 0))
		var move_normal = Vector3(move_vector.x, 0, move_vector.z)
		var target_position = player.transform.origin + move_normal
		var new_transform = player.transform.looking_at(target_position, Vector3.UP)
		player.transform  = player.transform.interpolate_with(new_transform, rotate_speed * delta)
		if player.translation.distance_to(path[0]) < 0.5:
			path.remove(0)
	else:
		get_target()

func is_book_on_map(book_type):
	var books = get_tree().get_nodes_in_group("books")
	for book in books:
		if book.item_name == book_type:
			return true
	return false

func get_target():
	var books = get_tree().get_nodes_in_group("books")
	var closest = null
	var need = want
	var players = get_tree().get_nodes_in_group("players")
	for enemy in players:
		if enemy.player_name != player.player_name:
			for book_type in book_types:
				if !enemy.inventory_hidden and enemy.inventory.count(book_type) == 3 and is_book_on_map(book_type):
#					print("Player " + enemy.player_name + " needs to be prevented from getting all " + book_type)
					need = book_type 
	if !is_book_on_map(need):
		for book_type in book_types:
			if is_book_on_map(book_type):
				need = book_type
	for book in books:
		if book.item_name == need and book.is_pickable():
			var distance =  book.translation.distance_to(player.translation)
			if distance > 1:
				if !closest or distance < closest.translation.distance_to(player.translation):
					closest = book
	target = closest
	if target:
		path = player.get_parent().get_node("Navigation").get_simple_path(player.translation, target.translation)
	elif home:
		path = player.get_parent().get_node("Navigation").get_simple_path(player.translation, home)
