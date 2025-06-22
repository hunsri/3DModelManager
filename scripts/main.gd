extends Node3D

@export var url := "ws://127.0.0.1:8000/ws-cube"
var ws: WebSocketPeer = WebSocketPeer.new()
var mesh_root: Node

var save_path = "user://models/"

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_W):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	if event is InputEventKey and Input.is_key_pressed(KEY_S):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED

func _ready():
	# allow up to 20 MB frames
	ws.inbound_buffer_size = 20 * 1024 * 1024
	
	mesh_root = Node3D.new()
	add_child(mesh_root)
	if ws.connect_to_url(url) != OK:
		printerr("WS connect failed")
		return
	set_process(true)
	
	load_model()

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
	
	print("done saving")
	
	file.close()
	
	ZipConverter.extract_all_from_zip(save_path_to_model,"user://models")
	
	load_model()

func load_model():
	if FileAccess.file_exists("user://models/model.glb"):
		print("glb Model Found!")
	
		var gltf := GLTFDocument.new()
		var gltf_state := GLTFState.new()
		var path = "user://models/model.glb"
		var snd_file = FileAccess.open(path, FileAccess.READ)
		var fileBytes = PackedByteArray()
		fileBytes = snd_file.get_buffer(snd_file.get_length())
		gltf.append_from_buffer(fileBytes, "base_path?", gltf_state, 8)
		var node = gltf.generate_scene(gltf_state)
		add_child(node)
	
	elif FileAccess.file_exists("user://models/model/model.obj"):
		print("obj Model Found!")
		
		var mesh:Mesh = ObjParse.load_obj("user://models/model/model.obj", "user://models/model/model.mtl")
		var mesh3d:MeshInstance3D = MeshInstance3D.new()
		mesh3d.mesh = mesh
		
		add_child(mesh3d)
	
	else:
		print("no model found!")
