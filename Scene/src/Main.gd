extends Node


const block_scene = preload("res://Scene/Block.tscn")


func _ready():
	# create test map
	for i in range(20):
		for j in range(20):
			var block = block_scene.instance()
			
			block.transform.origin.x = j * 2
			block.transform.origin.z = i * 2
			
			add_child(block)
