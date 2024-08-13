extends Node3D

const SPEED = 40.0
 
@onready var mesh = $MeshInstance3D

@onready var ray = $RayCast3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis	* Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		ray.enabled = false
		
		if ray.get_collision_mask_value(2):
			ray.get_collider().hit()
	pass
