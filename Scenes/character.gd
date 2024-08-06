extends CharacterBody3D

@onready var camera = $Camera3D

# Movement constants 
const SPEED = 10.0
const JUMP_VELOCITY = 9
const MOUSE_SENSIVITY = 0.01

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	pass

func _ready():
	if not is_multiplayer_authority(): return
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	pass

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	pass

func _input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	
