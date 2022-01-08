extends Spatial

var names_first = [ 
	"Arnold", "Angela", 
	"Bonnie", "Bert", 
	"Claire", "Connor", 
	"Donald", "Daisy",
	"Ernie", "Elsa",
	"Fred", "Fran",
	"Gary", "Ginny",
	"Harry", "Helen",
	"Igor", "Iris",
	"Jim", "Jane", 
	"Ken", "Kim",
	"Lenny", "Lara",
	"Max", "May",
	"Otto", "Olivia",
	"Pete", "Petra",
	"Quentin", "Queen",
	"Rory", "Reine",
	"Stan", "Sally",
	"Tony", "Tanya",
	"Ugo", "Ursula",
	"Vin", "Vala",
	"Xavier", "Xantippe",
	"Yves", "Yvon",
	"Zoro", "Zara"
	]

var names_last = [
	"Anderson",
	"Becker",
	"Carson",
	"Davies",
	"Edison",
	"Finkers",
	"Grant",
	"Hansen",
	"Ink",
	"Jones",
	"King",
	"Lambert",
	"Mobius",
	"Oldman",
	"Pinkman",
	"Quest",
	"Red",
	"Smith",
	"Travers",
	"Untied",
	"Venter",
	"Winters",
	"X",
	"Yonder",
	"Zever"
]

var options = [ "Barbarian", "Rogue", "Mage" ]
var current = 1
var descriptions = {
	"Rogue": """[b]Rogue[/b]
The Rogue can use the [i]pickpocket[/i] short range ability, to steal a book from opponents.
""",
	"Mage": """[b]Mage[/b]
The Mage can use the [i]swap trap[/i] ability, which will swap a book with an opponent who triggers the trap.
""",
	"Barbarian": """[b]Barbarian[/b]
The barbarian can use the [i]stomp[/i] ability to intimidate opponents into dropping all their books.
"""
}

# Called when the node enters the scene tree for the first time.
func _ready():
	names_first.shuffle()
	names_last.shuffle()
	var random_name = names_first[0] + " " + names_last[0]
	
	$Rogue/AnimationPlayer.play("idle")
	$Mage/AnimationPlayer.play("idle")
	$Barbarian/AnimationPlayer.play("idle")
	$Camera/AnimationPlayer.play("rogue")
	$CanvasLayer/bottom_center/Panel/description.bbcode_text = descriptions[options[current]]
	$CanvasLayer/top_center/Panel/MarginContainer/VBoxContainer/player_name.text = random_name

func refresh():
	Game.player_class = options[current]
	$Camera/AnimationPlayer.play(options[current])
	$CanvasLayer/bottom_center/Panel/description.bbcode_text = descriptions[options[current]]
	
func _input(event):
	if event.is_action_pressed("ui_left"):
		_on_select_left_pressed()
	if event.is_action_pressed("ui_right"):
		_on_select_right_pressed()

func _on_select_left_pressed():
		current -= 1
		if current < 0:
			current = 2
		refresh()


func _on_select_right_pressed():
		current += 1
		if current > 2:
			current = 0
		refresh()


func _on_start_pressed():
	Game.player_name = $CanvasLayer/top_center/Panel/MarginContainer/VBoxContainer/player_name.text
	get_tree().change_scene("res://Levels/LevelIntro.tscn")



func _on_button_hover():
	$hover.play()
