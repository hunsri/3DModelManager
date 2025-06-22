extends Node3D

@onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready():
	
	var animation_name
	
	for name in anim_player.get_animation_list():
		print("→", name)
		animation_name = name
		
	anim_player.play(animation_name)
	var anim : Animation = anim_player.get_animation(animation_name)
	anim.loop_mode = (Animation.LOOP_PINGPONG)
