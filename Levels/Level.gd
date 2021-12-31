extends Spatial

var playlog = []
var walk_speed = 10
var rotate_speed = 5
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
	if movement[MOVE.IDLE]:
		$Player.play("idle")
#		$Player/Rogue/AnimationPlayer.play("idle")
	else:
		$Player.play("run")
#		$Player/Rogue/AnimationPlayer.play("run")

func _ready():
	animate()
	print("Player: ", Game.player_name)
	print("Class: ", Game.player_class)
	$Player/PlayerName.text = Game.player_name
	$Player.select(Game.player_class)
	writelog("[i]" + Game.player_name + "[/i] has entered the map!")

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
#	move_vector.y = 0.5 #gravity
	if !$Player.is_on_wall():
		move_vector.y = 0.5
	$Player.move_and_slide (-1 * walk_speed * move_vector, Vector3(0, 1, 0))
	var move_normal = Vector3(move_vector.x, 0, move_vector.z)
	var target_position = $Player.transform.origin + move_normal
	var new_transform = $Player.transform.looking_at(target_position, Vector3.UP)
	$Player.transform  = $Player.transform.interpolate_with(new_transform, rotate_speed * delta)

func _on_resume_pressed():
	get_tree().paused = false
	$CanvasLayer/center/menu_buttons.hide()


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menus/MainMenu.tscn")
