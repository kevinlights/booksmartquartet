extends Control


var avatars = []
var pressed_any_key = false

func _input(event):
	if not pressed_any_key and event is InputEventKey and event.pressed:
		$press_any_key.play("intro")
		pressed_any_key = true
	if not pressed_any_key and event is InputEventMouseButton and event.pressed:
		$press_any_key.play("intro")
		pressed_any_key = true

func _enter_tree():
	pressed_any_key = false
	
func _ready():
	var feed_data = load_cached_feed()
	if feed_data:
		render_toots(feed_data.result)
	$fetch_mastodon_feed.request("https://fosstodon.org/api/v1/timelines/tag/booksmartquartet")

func _on_Button_pressed():
	get_tree().change_scene("res://Components/CharacterSelector.tscn")

func sanitize(html):
	var spans = RegEx.new()
	var breaks = RegEx.new()
	spans.compile("</*span.*?>")
	breaks.compile("<br.*?>")
	var sanitized = html.replace("<p>", "").replace("</p>", "\n")
	sanitized = sanitized.replace("&apos;", "'").replace("&quot;", '"').replace("&amp;", "&").replace("&nbsp;", " ").replace("&gt;", ">").replace("&lt;", "<")
	sanitized = spans.sub(sanitized, "", true)
	sanitized = breaks.sub(sanitized, "\n", true)
	return sanitized

func html2bbcode(html):
	var link_pattern = RegEx.new()
	link_pattern.compile("""<a.*?href=\\"(.*?)\\"\\s.*?>(.*?)</a>""")
	var links = link_pattern.sub(html, "[url=$1]$2[/url]", true)
	return links

func load_cached_feed():
	var cache_path = "user://mastodon_feed.json"
	var file = File.new()
	if file.file_exists(cache_path):
		file.open(cache_path, File.READ)
		var content = JSON.parse(file.get_as_text())
		file.close()
		return content
	return false

func save_cached_feed(text):
	var cache_path = "user://mastodon_feed.json"
	var file = File.new()
	file.open(cache_path, File.WRITE)
	file.store_string(text)
	file.close()
	
func render_toots(data):
	for i in range(0, $gui_root/top_right/social_panel/social_scroller/margin/social.get_child_count()):
		$gui_root/top_right/social_panel/social_scroller/margin/social.get_child(i).queue_free()
	for toot in data:
		var original_toot = toot
		if toot.reblog:
			original_toot = toot.reblog
		var bbcode = html2bbcode(sanitize(original_toot.content))
		var mastodon = load("Menus/mastodon.tscn").instance()
		var avatar = Avatar.new(original_toot.account.avatar_static, mastodon.get_node("margin/toot_vertical/toot_title/avatar"))
		avatars.append(avatar)
		add_child(avatar)
		avatar.save()
		var name = original_toot.account.display_name
		if name == "":
			name = original_toot.account.username
		mastodon.get_node("margin/toot_vertical/toot_title/display_name").text = name
		mastodon.get_node("margin/toot_vertical/toot").bbcode_text = bbcode.strip_edges(true, true)
		$gui_root/top_right/social_panel/social_scroller/margin/social.add_child(mastodon)

func _on_fetch_mastodon_feed_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var data = body.get_string_from_utf8()
		print("Downloaded statuses from mastodon")
		save_cached_feed(data)
		var json_result = JSON.parse(data)
		render_toots(json_result.result)

func _on_matrix_pressed():
	OS.shell_open("https://matrix.to/#/#fedijam:m.wfr.moe")

func _on_mastodon_pressed():
	OS.shell_open("https://fosstodon.org/@armen")

func _on_gitlab_pressed():
	OS.shell_open("https://gitlab.com/armen138/booksmartquartets")

func _on_play_pressed():
	get_tree().change_scene("res://Components/CharacterSelector.tscn")


func _on_credits_pressed():
	get_tree().change_scene("res://Menus/Credits.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_fedinews_pressed():
	$gui_root/top_right/animate_social.play_backwards("toggle")


func _on_close_fedinews_pressed():
	$gui_root/top_right/animate_social.play("toggle")


func _on_options_pressed():
	get_tree().change_scene("res://Menus/Options.tscn")


func _on_button_hover():
	$hover.play()
