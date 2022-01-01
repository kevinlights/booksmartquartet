extends Spatial

var is_player = true
var local = true
var inventory = []
onready var avatar = $Rogue

onready var camera = get_tree().get_root().get_node("Level/CameraAnchor/FollowCamera")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_to_inventory(item):
	inventory.append(item)
	if inventory.size() > 5:
		var drop = inventory.pop_front()
		var item_drop = load("Components/Item.tscn").instance()
		item_drop.item_name = drop
		item_drop.translation = translation
		get_parent().add_child(item_drop)
		get_parent().writelog("[i]" + Game.player_name + "[/i] has dropped " + drop)
	get_parent().writelog("[i]" + Game.player_name + "[/i] has picked up " + item)
	get_parent().get_node("CanvasLayer/bottom_center/inventory").set_items(inventory)

func remove_from_inventory(item):
	pass

func select(player_class):
	$Mage.hide()
	$Rogue.hide()
	$Barbarian.hide()
	avatar = get_node(player_class)
	avatar.show()

func play(animation):
	avatar.get_node("AnimationPlayer").play(animation)

func _process(delta):
	var label_position = camera.unproject_position(translation + Vector3(0, 3, 0))
	$PlayerName.rect_position.x = label_position.x - 100
	$PlayerName.rect_position.y = label_position.y
	
