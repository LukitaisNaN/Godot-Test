extends CharacterBody3D

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer

@onready var ak = $weapon/RayCast3D


var bullet = load("res://Weapons/bullet.tscn")
var instance
var health = 100

# Movement constants 
const SPEED = 10.0
const JUMP_VELOCITY = 9
const MOUSE_SENSIVITY = 0.003
const GRAVITY = 20

# Weapons Cooldowns
var ak_cooldown = 0.3

# Animations
enum ANIMATIONS {IDLE, RUN, JUMP, SHOOT, SLIDE, GRENADE}
var current_animation:ANIMATIONS
var my_tree:AnimationTree

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	pass

func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	my_tree = $AnimationTree
	# my_tree.set_active(true)
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
		camera.rotation.x = clamp(camera.rotation.x, -PI/3, PI/2)
		
	# Release mouse
	if Input.is_action_just_pressed("quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Grab mouse
	if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED) and Input.is_action_just_pressed("shoot"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		# my_tree.set("parameters/one_shot_control", 1)
		
	if Input.is_action_just_pressed("dash"):
		my_tree.set("parameters/s_j_g", -1)
		animate(ANIMATIONS.SLIDE)
		
	if Input.is_action_just_pressed("jump"):
		my_tree.set("parameters/s_j_g", 0)
		animate(ANIMATIONS.JUMP)
	
	pass

func shoot():
	# if ak_cooldown <= 0:
		# add shooting code
		# ak_cooldown = 0.3
	
	instance = bullet.instantiate()
	instance.position = ak.global_position
	instance.transform.basis = ak.global_transform.basis
	get_parent().add_child(instance)

func hit(dam):
	health -= dam
	if health <= 0:
		queue_free()

func animate(animation_name:ANIMATIONS):
	
	match(animation_name):
		
		# Main animations
		ANIMATIONS.SHOOT: 
			anim_player.play("shoot")
			# my_tree.set("parameters/one_shot_control/request/fire", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		ANIMATIONS.RUN: 
			anim_player.play("Run")
			# my_tree.set("parameters/run_idle", 1)
		ANIMATIONS.IDLE: 
			anim_player.play("idle")
			# my_tree.set("parameters/run_idle", 0)
		
		# Actions
		ANIMATIONS.JUMP: 
			anim_player.play("jump")
			# my_tree.set("parameters/one_shot_control/request/fire", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		ANIMATIONS.SLIDE: 
			anim_player.play("slide")
			# my_tree.set("parameters/one_shot_control/request/fire", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
		# Special 
		ANIMATIONS.GRENADE:
			anim_player.play("grenade_throw")
			# my_tree.set("parameters/one_shot_control", 1)
	pass
