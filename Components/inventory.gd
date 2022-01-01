extends HBoxContainer

var inventory = []
var known_items = [
	"Red Book",
	"Blue Book",
	"Green Book",
	"Brown Book"
]

func _ready():
	refresh()

func refresh():
	var slots = [ $item, $item2, $item3, $item4, $item5 ]
	for slot in slots:
		for known_item in known_items:
			slot.get_node(known_item).hide()
	for item in inventory:
		if slots.size() > 0:
			var slot = slots.pop_front()
			slot.get_node(item).show()

func set_items(items):
	inventory = items
	refresh()

func add(item):
	if inventory.size() == 5:
		return false
	inventory.append(item)
	refresh()
	return true

func remove(item):
	inventory.erase(item)
	refresh()
