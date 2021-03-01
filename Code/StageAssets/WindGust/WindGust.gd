tool
extends Area2D

const kParticlesPerPixel := 0.05

export var extents := Vector2(10.0, 10.0) setget set_extents
export var magnitude := 0.1 setget set_magnitude

var forceVector := Vector2.ZERO
var objects := []

func set_extents(val: Vector2):
	extents = val
	if get_node_or_null("CollisionShape2D") != null:
		var shape := RectangleShape2D.new()
		shape.extents = extents
		$CollisionShape2D.shape = shape
	update_particles()
		
func set_magnitude(val: float):
	magnitude = val
	update_particles()
	
func update_particles():
	if get_node_or_null("Particles2D") != null:
		($Particles2D.process_material as ParticlesMaterial).initial_velocity = 400.0 * magnitude + 100.0
		#$Particles2D.amount = int(5 * kParticlesPerPixel * extents.x * extents.y)
		#$Particles2D.lifetime = 0.2 * extents.x * extents.y / 100.0
		($Particles2D.process_material as ParticlesMaterial).emission_box_extents = 6 * Vector3(extents.x, extents.y, 0.0)
		$Particles2D.visibility_rect = Rect2(-6 * extents, 12 * extents)
	
func _ready():
	set_extents(extents)
	var forceAngle := rotation - PI / 2.0
	forceVector = magnitude * Vector2(cos(forceAngle), sin(forceAngle))
	Utility.print_errors([
		connect("body_entered", self, "entered"),
		connect("body_exited", self, "exited"),
	])
	$Particles2D.process_material = $Particles2D.process_material.duplicate()
	
func _physics_process(delta):
	for i in objects:
		if "velocity" in i:
			i.velocity += GlobalData.gravity * forceVector * delta
		elif "linear_velocity" in i:
			i.linear_velocity += GlobalData.gravity * forceVector * delta
	
func entered(other: CollisionObject2D):
	if other != null:
		objects.append(other)
	
func exited(other: CollisionObject2D):
	if other != null:
		objects.erase(other)
