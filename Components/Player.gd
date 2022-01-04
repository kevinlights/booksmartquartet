extends Spatial

var player_name = ""
var is_player = true
var local = true
var inventory = []
var inventory_node = null
var inventory_hidden = false
var last_special_action = -1
var special_action_cooldown = 6000
var cooldown_bar = null
var action_names = {
	"Rogue": "pickpocket",
	"Mage": "swap",
	"Barbarian": "stomp"
}
onready var avatar = $Rogue

onready var camera = get_tree().get_root().get_node("Level/CameraAnchor/FollowCamera")
# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_bar = get_parent().get_node("CanvasLayer/bottom_center/Cooldown")
	apply_settings()

func apply_settings():
	if Game.shadows:
		$SpotLight.shadow_enabled = true

func add_to_inventory(item):
	inventory.append(item)
	if inventory.size() > 5:
		var drop = inventory.pop_front()
		var item_drop = load("Components/Item.tscn").instance()
		item_drop.item_name = drop
		item_drop.translation = translation
		get_parent().add_child(item_drop)
		get_parent().writelog("[i]" + player_name + "[/i] has dropped " + drop)
	get_parent().writelog("[i]" + player_name + "[/i] has picked up " + item)
	if local:
		get_parent().get_node("CanvasLayer/bottom_center/inventory").set_items(inventory)
	elif inventory_node:
		inventory_node.get_node("Inventory").set_items(inventory)
func remove_from_inventory(item):
	pass

func perform_action():
	var now = OS.get_ticks_msec()
	if now - last_special_action > special_action_cooldown:
		last_special_action = now
		print("Request special action")
		cooldown_bar.show()
	else:
		print("Cooldown special action active")

func select(player_class):
	$Mage.hide()
	$Rogue.hide()
	$Barbarian.hide()
	avatar = get_node(player_class)
	avatar.show()
	cooldown_bar.get_node("ActionName").text = action_names[player_class] + " cooldown"

func play(animation):
	avatar.get_node("AnimationPlayer").play(animation)

func _process(delta):
	var now = OS.get_ticks_msec()
	if local:
		var last_action_progress = now - last_special_action
		if last_special_action != -1 and last_action_progress < special_action_cooldown:
			if !cooldown_bar.visible:
				cooldown_bar.show()
			var pct = 100.0 - (100.0 / special_action_cooldown * last_action_progress)
			cooldown_bar.value = pct
		elif cooldown_bar.visible and last_action_progress > special_action_cooldown:
			cooldown_bar.hide()
	var label_position = camera.unproject_position(translation + Vector3(0, 3, 0))
	$PlayerName.rect_position.x = label_position.x - 100
	$PlayerName.rect_position.y = label_position.y

