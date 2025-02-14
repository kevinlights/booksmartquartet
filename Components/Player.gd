extends Spatial

var player_name = ""
var character_class = "Rogue"
var is_player = true
var local = true
var inventory = []
var inventory_node = null
var inventory_hidden = false
var last_special_action = -1
var special_action_cooldown = 6000
var cooldown_bar = null
var action_hint = null
var action_names = {
	"Rogue": "pickpocket",
	"Mage": "swap trap",
	"Barbarian": "stomp"
}
var action_verbed = {
	"Rogue": "pickpocketed",
	"Mage": "deployed swap trap",
	"Barbarian": "stomped"
}

var action_radius = {
	"Rogue": 2.0,
	"Mage": 0.0,
	"Barbarian": 4.0
}
onready var avatar = $Rogue

onready var camera = get_tree().get_root().get_node("Level/CameraAnchor/FollowCamera")
# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_bar = get_parent().get_node("CanvasLayer/bottom_center/Cooldown")
	action_hint = get_parent().get_node("CanvasLayer/bottom_center/ActionHint")
	apply_settings()

func apply_settings():
	if Game.shadows:
		$SpotLight.shadow_enabled = true

func add_to_inventory(item):
	inventory.append(item)
	if inventory.size() > 5:
		var random_offset = Vector3(rand_range(-4, 4), 0, rand_range(-4, 4))
		var drop = inventory.pop_front()
		var item_drop = load("Components/Item.tscn").instance()
		item_drop.item_name = drop
		item_drop.dropped_by = player_name
		item_drop.translation = translation + random_offset
		get_parent().add_child(item_drop)
		get_parent().writelog("[i]" + player_name + "[/i] has dropped " + drop)
	get_parent().writelog("[i]" + player_name + "[/i] has picked up " + item)
	if local:
		$pickup.play()
		get_parent().get_node("CanvasLayer/bottom_center/inventory").set_items(inventory)
	elif inventory_node:
		inventory_node.get_node("Inventory").set_items(inventory)
	for book_type in Game.book_types:
		var count = inventory.count(book_type)
		if count == 4:
			print("Winner declared: " + player_name + " with book " + book_type)
			get_parent().win(player_name, book_type)

func remove_from_inventory(item):
	inventory.erase(item)
	if local:
		get_parent().get_node("CanvasLayer/bottom_center/inventory").set_items(inventory)
	elif inventory_node:
		inventory_node.get_node("Inventory").set_items(inventory)

func drop_everything():
	for drop in inventory:
		var random_offset = Vector3(rand_range(-4, 4), 0, rand_range(-4, 4))
		var item_drop = load("Components/Item.tscn").instance()
		item_drop.item_name = drop
		item_drop.dropped_by = player_name
		item_drop.translation = translation + random_offset
		get_parent().add_child(item_drop)
		get_parent().writelog("[i]" + player_name + "[/i] has dropped " + drop)
	inventory = []
	if local:
		get_parent().get_node("CanvasLayer/bottom_center/inventory").set_items(inventory)
	elif inventory_node:
		inventory_node.get_node("Inventory").set_items(inventory)

func player_in_range():
	var players = get_tree().get_nodes_in_group("players")
	var target = null
	for other in players:
		other.get_node("targeted").hide()
		if other.player_name != player_name:
			if other.transform.origin.distance_to(transform.origin) < action_radius[character_class]:
				other.get_node("targeted").show()
				target = other
	return target

func transfer_trap():
	var books = [ "Red Book", "Green Book", "Blue Book", "Brown Book" ]
	books.shuffle()
	var random_offset = Vector3(rand_range(-4, 4), 0, rand_range(-4, 4))
	var drop = books[0]
	var item_drop = load("Components/Item.tscn").instance()
	item_drop.item_name = drop
	item_drop.dropped_by = player_name
	item_drop.is_trap = true
	item_drop.translation = translation + random_offset
	get_parent().add_child(item_drop)

func stomp(target_player):
	play("attack")
	$stomp.emitting = true
	target_player.play("defeat")
	target_player.drop_everything()

func swap(target):
	# this is a reverse pickpocket (mage ability)
	var players = get_tree().get_nodes_in_group("players")
	var target_player = null
	for player in players:
		if player.player_name == target:
			target_player = player
			break
	if !target_player:
		return
	var want = "Blue Book"
	var most = 0
	for book_type in Game.book_types:
		var count = target_player.inventory.count(book_type)
		if count > most:
			most = count
			want = book_type
	if inventory.count(want) == 0:
		if inventory.size() > 0:
			want = inventory[0]
		else:
			get_parent().writelog("Swap trap failed on [i]" + player_name + "[/i] because inventory was empty")
			return
	target_player.add_to_inventory(want)
	remove_from_inventory(want)
	get_parent().writelog("[i]" + player_name + "[/i] fell for [i]" + target + "[/i]'s swap trap!")
	
func pickpocket(target_player):
	var want = "Blue Book"
	var most = 0
	for book_type in Game.book_types:
		var count = inventory.count(book_type)
		if count > most:
			most = count
			want = book_type
	if target_player.inventory.count(want) == 0:
		if target_player.inventory.size() > 0:
			want = target_player.inventory[0]
		else:
			get_parent().writelog("Tried pickpocketing [i]" + target_player.player_name + "[/i] but inventory was empty")
			return
	add_to_inventory(want)
	target_player.remove_from_inventory(want)
		
func perform_action():
	var now = OS.get_ticks_msec()
	if character_class == "Mage":
		if now - last_special_action > special_action_cooldown:
			last_special_action = now
			$action.play()
			transfer_trap()
			get_parent().writelog("[i]" + player_name + "[/i] " + action_verbed[character_class])
		else:
			get_parent().writelog("Cooldown active")
		return
	var in_range = player_in_range()
	if !in_range:
		get_parent().writelog("No player in range")
	else:
		if now - last_special_action > special_action_cooldown:
			$action.play()
			last_special_action = now
			cooldown_bar.show()
			action_hint.hide()
			if character_class == "Rogue":
				pickpocket(in_range)
			elif character_class == "Barbarian":
				stomp(in_range)
			in_range.get_node("victimized").emitting = true
			play("attack")
			get_parent().writelog("[i]" + player_name + "[/i] " + action_verbed[character_class] + " [i]" + in_range.player_name + "[/i]")
		else:
			get_parent().writelog("Cooldown active")

func select(player_class):
	character_class = player_class
	$Mage.hide()
	$Rogue.hide()
	$Barbarian.hide()
	avatar = get_node(player_class)
	avatar.show()
	get_parent().get_node("CanvasLayer/bottom_center/Cooldown").get_node("ActionName").text = action_names[player_class] + " cooldown"

func current_animation():
	return avatar.get_node("AnimationPlayer").current_animation

func play(animation):
	avatar.get_node("AnimationPlayer").play(animation)

func _process(delta):
	var now = OS.get_ticks_msec()
	if local:
		var in_range = player_in_range()
		var last_action_progress = now - last_special_action
		if last_special_action != -1 and last_action_progress < special_action_cooldown:
			if !cooldown_bar.visible:
				cooldown_bar.show()
				action_hint.hide()
			var pct = 100.0 - (100.0 / special_action_cooldown * last_action_progress)
			cooldown_bar.value = pct
		elif cooldown_bar.visible and last_action_progress > special_action_cooldown:
			cooldown_bar.hide()
		else:
			if in_range:
				action_hint.show()
				action_hint.text = "<space> to " + action_names[character_class] + " " + in_range.player_name
			else:
				action_hint.hide()
	var label_position = camera.unproject_position(translation + Vector3(0, 3, 0))
	$PlayerName.rect_position.x = label_position.x - 100
	$PlayerName.rect_position.y = label_position.y

