class_name Avatar
extends Node

var url
var node

func _init(url, node):
	self.url = url
	self.node = node
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir("avatars")

func filename():
	var tokens = url.split("/")
	return tokens[tokens.size() -1]

func set_image(image):
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	self.node.texture = texture
	
func store(result, response_code, headers, body):
#	print(headers)
	var avatar_path = "user://avatars/" + filename()
	print(avatar_path)
	var file = File.new()
	var err = file.open(avatar_path, file.WRITE)
	print(err)
	file.store_buffer(body)
	file.close()
	var image = Image.new()
	if avatar_path.ends_with("png"):
		var error = image.load_png_from_buffer(body)
		if error != OK:
			push_error("Couldn't load the image.")
	elif avatar_path.ends_with("jpg") or avatar_path.ends_with("jpeg"):
		var error = image.load_jpg_from_buffer(body)
		if error != OK:
			push_error("Couldn't load the image.")
	else:
		print("Unsupported avatar format")
		return
	set_image(image)

func set_avatar_from_path(path):
	var file = File.new()
	file.open(path, File.READ)
	var image_buffer = file.get_buffer(file.get_len())
	file.close()
	var image = Image.new()
	if path.ends_with("png"):
		var error = image.load_png_from_buffer(image_buffer)
		if error != OK:
			push_error("Couldn't load the image.")
	elif path.ends_with("jpg") or path.ends_with("jpeg"):
		var error = image.load_jpg_from_buffer(image_buffer)
		if error != OK:
			push_error("Couldn't load the image.")
	else:
		print("Unsupported avatar format")
		return
	set_image(image)

func save():
	var avatar_path = "user://avatars/" + filename()
	var file = File.new()
	if file.file_exists(avatar_path):
		set_avatar_from_path(avatar_path)
	else:
		var http = HTTPRequest.new()
		add_child(http)
		http.connect("request_completed", self, "store")
		var result = http.request(url)
		if result != OK:
			print("Error encountered trying to download avatar ", result)

