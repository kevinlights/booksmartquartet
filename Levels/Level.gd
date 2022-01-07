extends Spatial

var playlog = []
var walk_speed = 10
var rotate_speed = 5
var enemy_inventories = []
enum MOVE {
	LEFT,
	RIGHT,
	FORWARD,
	BACK,
	IDLE
}

var movement = {
	MOVE.IDLE: false,
	MOVE.LEFT: false,
	MOVE.RIGHT: false,
	MOVE.FORWARD: false,
	MOVE.BACK: false
}

func writelog(item):
	playlog.append(item)
	$CanvasLayer/top_right/Log.bbcode_text = PoolStringArray(playlog).join("\n")

func animate():
	if $Player.current_animation() in Game.dont_interrupt:
		return false
	if movement[MOVE.IDLE]:
		$Player.play("idle")
	else:
		$Player.play("run")
	return true

func apply_settings():
	if Game.shadows:
		$DirectionalLight.shadow_enabled = true

func _ready():
	animate()
	enemy_inventories = [
		$CanvasLayer/top_left/EnemyInventory,
		$CanvasLayer/top_left/EnemyInventory2,
		$CanvasLayer/top_left/EnemyInventory3,
	]
	print("Player: ", Game.player_name)
	print("Class: ", Game.player_class)
	$Player/PlayerName.text = Game.player_name
	$Player.player_name = Game.player_name
	$Player.select(Game.player_class)
	writelog("[i]" + Game.player_name + "[/i] has entered the map!")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		writelog("[i]" + enemy.player_name + "[/i] has come online!")
		enemy.inventory_node = enemy_inventories.pop_front()
		enemy.inventory_node.show()
		enemy.inventory_node.get_node("PlayerName").text = enemy.player_name
	apply_settings()

func _input(event):
	movement[MOVE.IDLE] = true
	if event.is_action_pressed("forward"):
		movement[MOVE.FORWARD] = true
	if event.is_action_pressed("back"):
		movement[MOVE.BACK] = true
	if event.is_action_pressed("left"):
		movement[MOVE.LEFT] = true
	if event.is_action_pressed("right"):
		movement[MOVE.RIGHT] = true
	if event.is_action_released("forward"):
		movement[MOVE.FORWARD] = false
	if event.is_action_released("back"):
		movement[MOVE.BACK] = false
	if event.is_action_released("left"):
		movement[MOVE.LEFT] = false
	if event.is_action_released("right"):
		movement[MOVE.RIGHT] = false
	if event.is_action_pressed("action"):
		$Player.perform_action()
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		$CanvasLayer/center/menu_buttons.show()
	for direction in movement:
		if movement[direction] and direction != MOVE.IDLE:
			movement[MOVE.IDLE] = false
	animate()

func _physics_process(delta):
	var move_vector = Vector3()
	if movement[MOVE.FORWARD]:
		move_vector.z = -1
	if movement[MOVE.BACK]:
		move_vector.z = 1
	if movement[MOVE.LEFT]:
		move_vector.x = -1
	if movement[MOVE.RIGHT]:
		move_vector.x = 1
	if !$Player.is_on_wall() and !$Player.is_on_floor():
		move_vector.y = 0.5

	if !($Player.current_animation() in Game.dont_walk):
		$Player.move_and_slide (-1 * walk_speed * move_vector, Vector3(0, 1, 0))
		var move_normal     = Vector3(move_vector.x, 0, move_vector.z)
		var target_position = $Player.transform.origin + move_normal
		var new_transform   = $Player.transform.looking_at(target_position, Vector3.UP)
		$Player.transform   = $Player.transform.interpolate_with(new_transform, rotate_speed * delta)

func win(player_name, book_type):
	get_tree().paused = true
	$CanvasLayer/center/win/winner.text = "Winner: " + player_name
	$CanvasLayer/center/win.get_node(book_type).show()
	$CanvasLayer/center/win.show()

func _on_resume_pressed():
	get_tree().paused = false
	$CanvasLayer/center/menu_buttons.hide()


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menus/MainMenu.tscn")


func _on_dismiss_win_pressed():
	_on_quit_pressed()
