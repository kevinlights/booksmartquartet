extends Spatial

onready var target = get_parent().get_node("Player")

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	translation.x = target.translation.x
	translation.y = target.translation.y
	translation.z = target.translation.z
