extends KinematicBody


var moveSpeed : float = 5.0
var jumpForce : float = 12
var gravity : float = 25.0

var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()

onready var camera : Camera = get_node("Camera")
onready var cast = get_node("RayCast")
onready var highlighter = get_parent().get_node("HighLighter")


var mouse_visible = false
var block_index = 0
var block_textures = [
	load("res://texture/grass_texture.png"),
	load("res://texture/soil_texture.png"),
	load("res://texture/rock_texture.png"),
	load("res://texture/sand_texture.png"),
	load("res://texture/coal_texture.png"),
	load("res://texture/gold_texture.png"),
]


const block_scene = preload("res://Scene/Block.tscn")


signal highlight_block(block_x, block_y, block_z)
signal unhighlight_block


func createBlock(x, y, z):
	var block = block_scene.instance()
	var mat = SpatialMaterial.new()
	
	mat.albedo_texture = block_textures[block_index]
	
	block.get_node("MeshInstance").material_override = mat
	
	block.transform.origin.x = x
	block.transform.origin.y = y
	block.transform.origin.z = z
	
	get_parent().add_child(block)


func _physics_process(delta):
	vel.x = 0
	vel.z = 0
  
	var input = Vector2()
  
	# movement inputs
	if Input.is_action_pressed("forward"):
		input.y -= 1
		
	if Input.is_action_pressed("backward"):
		input.y += 1
		
	if Input.is_action_pressed("left"):
		input.x -= 1
		
	if Input.is_action_pressed("right"):
		input.x += 1
	
	if Input.is_action_just_pressed("1"):
		block_index = 0
	
	if Input.is_action_just_pressed("2"):
		block_index = 1
		
	if Input.is_action_just_pressed("3"):
		block_index = 2
		
	if Input.is_action_just_pressed("4"):
		block_index = 3
		
	if Input.is_action_just_pressed("5"):
		block_index = 4
		
	if Input.is_action_just_pressed("6"):
		block_index = 5
		
	if Input.is_action_just_pressed("escape"):
		if mouse_visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_visible = true
	
	input = input.normalized()
  
	# get the forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
  
	var relativeDir = (forward * input.y + right * input.x)
  
	# set the velocity
	vel.x = relativeDir.x * moveSpeed
	vel.z = relativeDir.z * moveSpeed
  
	# apply gravity
	vel.y -= gravity * delta
  
	# move the player
	vel = move_and_slide(vel, Vector3.UP)
  
	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y = jumpForce
	
	if cast.is_colliding():
		var block = cast.get_collider()
		var block_x = block.transform.origin.x
		var block_y = block.transform.origin.y
		var block_z = block.transform.origin.z
		
		emit_signal("highlight_block", block_x, block_y, block_z)
		
		if Input.is_action_just_pressed("left_click"):
			block.queue_free()
		
		if Input.is_action_just_pressed("right_click"):
			if cast.get_collision_point().z >= block_z + 1:
				createBlock(block_x, block_y, block_z + 2)
			elif cast.get_collision_point().z <= block_z - 1:
				createBlock(block_x, block_y, block_z - 2)
			elif cast.get_collision_point().x >= block_x + 1:
				createBlock(block_x + 2, block_y, block_z)
			elif cast.get_collision_point().x <= block_x - 1:
				createBlock(block_x - 2, block_y, block_z)
			elif cast.get_collision_point().y >= block_y + 1:
				createBlock(block_x, block_y + 2, block_z)
			elif cast.get_collision_point().y <= block_y - 1:
				createBlock(block_x, block_y - 2, block_z)
	else:
		emit_signal("unhighlight_block")


func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative


func _process(delta):
	# rotate the camera along the x axis
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	cast.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	
	# clamp camera x rotation axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	cast.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
	# rotate the player along their y-axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta

	# reset the mouseDelta vector
	mouseDelta = Vector2()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cast.add_exception(highlighter)
