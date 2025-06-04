extends Node3D

@export var url := "ws://127.0.0.1:8000/ws-cube"
var ws: WebSocketPeer = WebSocketPeer.new()
var mesh_root: Node

var save_path = "user://models/"

func _ready():
	#ws.set_max_message_size(20 * 1024 * 1024)  # allow up to 20 MB frames
	ws.inbound_buffer_size = 20 * 1024 * 1024
	
	mesh_root = Node3D.new()
	add_child(mesh_root)
	if ws.connect_to_url(url) != OK:
		printerr("WS connect failed")
		return
	set_process(true)

func _process(_delta):
	ws.poll()
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN and ws.get_available_packet_count() > 0:
		var raw: PackedByteArray = ws.get_packet()
		
		saving_file(raw)
		
	elif ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		set_process(false)

func saving_file(data: PackedByteArray):
	var save_path_to_model := "user://temp/download.zip"
	
	var dir = DirAccess.open("user://")
	dir.make_dir_recursive("user://temp/")
	
	var file = FileAccess.open(save_path_to_model, FileAccess.WRITE)
	
	print("start saving")
	
	for i in data.size():
		file.store_8(data.get(i))
		print(str(data.get(i))+", ")
	
	print("done saving")
	
	file.close()
	
	ZipConverter.extract_all_from_zip(save_path_to_model,"user://models")
	
	
	if FileAccess.file_exists("user://model.glb"):
		print("glb Model Found!")
	
		var gltf := GLTFDocument.new()
		var gltf_state := GLTFState.new()
		var path = save_path_to_model
		var snd_file = FileAccess.open(path, FileAccess.READ)
		var fileBytes = PackedByteArray()
		fileBytes = snd_file.get_buffer(snd_file.get_length())
		gltf.append_from_buffer(fileBytes, "base_path?", gltf_state, 8)
		var node = gltf.generate_scene(gltf_state)
		add_child(node)
	
	if FileAccess.file_exists("user://models/model.obj"):
		print("obj Model Found!")
		
		var mesh:Mesh = ObjParse.load_obj("user://models/model.obj", "user://models/model.mtl")
		var mesh3d:MeshInstance3D = MeshInstance3D.new()
		mesh3d.mesh = mesh
		
		add_child(mesh3d)

###Experimental stuff to load non glb files into res to load them
#Not needed anymore as of now
func copy_models():
	self.copy_dir_recursively(save_path, "res://models/")

func copy_dir_recursively(source: String, destination: String):
	DirAccess.make_dir_recursive_absolute(destination)
	
	var source_dir = DirAccess.open(source);
	
	for filename in source_dir.get_files():
		OS.alert(source + filename, 'Datei erkannt')
		source_dir.copy(source + filename, destination + filename)
		
	for dir in source_dir.get_directories():
		self.copy_dir_recursively(source + dir + "/", destination + dir + "/")
