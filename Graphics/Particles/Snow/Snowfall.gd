tool
extends Particles2D

export var velocity := 72.0 setget set_vel
export var direction := Vector3(1.0, 1.0, 0.0) setget set_dir
export var particlesPerScreen := 16 setget set_pps

func set_vel(val: float):
	velocity = val
	update_material()

func set_dir(val: Vector3):
	direction = val
	update_material()

func set_pps(val: int):
	particlesPerScreen = val
	update_material()

func update_material():
	emitting = false
	var mat := process_material as ParticlesMaterial
	lifetime = 98.0 / velocity
	mat.initial_velocity = velocity
	mat.direction = direction
	
	if get_parent() != null && get_parent().has_node("StageBg"):
		var stageBg := get_parent().get_node("StageBg") as StageBg
		position = (stageBg.rect_position + stageBg.rect_size / 2.0)
		mat.emission_box_extents = Vector3(stageBg.rect_size.x / 2.0, stageBg.rect_size.y / 2.0, 0.0)
		self.visibility_rect = Rect2(-stageBg.rect_size / 2.0, stageBg.rect_size)
		amount = int(particlesPerScreen * stageBg.screen_size.get_area())
	else:
		amount = particlesPerScreen
	emitting = true

func _ready():
	process_material = process_material.duplicate(true)
	update_material()
	
#func _process(delta):
#	if GlobalData.camera != null:
#		global_position = GlobalData.camera.global_position
