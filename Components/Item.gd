tool
extends Spatial

export(String, "Blue Book", "Green Book", "Red Book", "Brown Book") var item_name = "Blue Book"
var picked_up = false
var creation_time = 0
var delay_pickable = 2000

var item_colors = {
	"Blue Book": Color(0, 0.403922, 0.545098, 0.611765),
	"Red Book": Color(0.635294, 0.023529, 0.039216, 0.721569),
	"Green Book": Color(0.282353, 0.541176, 0.145098, 0.792157),
	"Brown Book": Color(0.490196, 0.25098, 0.164706, 0.752941)
}

func _ready():
	creation_time = OS.get_ticks_msec()
	$CPUParticles.color = item_colors[item_name]

func is_pickable():
	var now = OS.get_ticks_msec()
	return now - creation_time > delay_pickable

func _on_pickup_body_entered(body):
	var now = OS.get_ticks_msec()
	if not picked_up and "is_player" in body and body.is_player and now - creation_time > delay_pickable:
		picked_up = true
		body.add_to_inventory(item_name)
		$Animation.play("pickup")
		body.play("cheer")
		queue_free()

func _process(delta):
	$CPUParticles.color = item_colors[item_name]
