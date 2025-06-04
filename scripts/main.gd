extends Node3D

@export var url := "ws://127.0.0.1:8000/ws-cube"
var ws: WebSocketPeer = WebSocketPeer.new()
var mesh_root: Node

var save_path = "user://models/"

func _ready():
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
	var save_path_to_model := "user://models/model.obj"
	
	#var file = FileAccess.open(save_path_to_model, FileAccess.WRITE)
#
	#for i in data.size():
		#file.store_8(data.get(i))
	#
	#file.close()
	
	print(ResourceLoader.exists("user://model.glb"))
	
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
		
		#copy_models()
		
		#load("res://models/model.obj")
		var mesh:Mesh = ObjParse.load_obj("user://models/model.obj", "user://models/model.mtl")
		var mesh3d:MeshInstance3D = MeshInstance3D.new()
		mesh3d.mesh = mesh
		
		add_child(mesh3d)
