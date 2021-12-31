extends Spatial

var is_player = true
var local = true
var inventory = []
onready var avatar = $Rogue

onready var camera = get_tree().get_root().get_node("Level/CameraAnchor/FollowCamera")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
	
