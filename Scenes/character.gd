extends CharacterBody3D

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var flash = $weapon/flash

# Movement constants 
const SPEED = 10.0
const JUMP_VELOCITY = 9
const MOUSE_SENSIVITY = 0.01
const GRAVITY = 20

var cooldown = 0.3

# Animations
enum ANIMATIONS {JUMP, IDLE, RUN, SHOOT, SLIDE}
var current_animation:ANIMATIONS

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	pass

func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	pass

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add gravity.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		
	# Don't move if mouse is outside screen, 
	# but still apply gravity.
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: 
		move_and_slide()
		return
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		current_animation = ANIMATIONS.RUN
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		current_animation = ANIMATIONS.IDLE

	move_and_slide()
	animate(current_animation)

func _input(event):
	if not is_multiplayer_authority(): return
	
	# Rotate Camera
	if event is InputEventMouseMotion and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		rotate_y(-event.relative.x * MOUSE_SENSIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	# Release mouse
	if Input.is_action_just_pressed("quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Grab mouse
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and Input.is_action_just_pressed("shoot"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		current_animation =ANIMATIONS.SHOOT 
	pass

func shoot():
	if cooldown <= 0:
		flash.emitting = true
		cooldown = 0.3
	
func slide():
	current_animation
	pass
	
func animate(animation_name:ANIMATIONS):
	match(animation_name):
		ANIMATIONS.SHOOT: shoot()
		ANIMATIONS.RUN: anim_player.play("Run")
		ANIMATIONS.JUMP: anim_player.play("jump")
		ANIMATIONS.IDLE: anim_player.play("idle")
		ANIMATIONS.SLIDE: anim_player.play("slide")
	pass
