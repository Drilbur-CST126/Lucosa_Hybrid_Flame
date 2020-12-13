extends Sprite

export var duration := 0.0
export var velocity := Vector2(0.0, 0.0)
export var velocity_random := Vector2(0.0, 0.0)
export var acceleration := Vector2(0.0, 0.0)
export var acceleration_random := Vector2(0.0, 0.0)
export var fps := 0
export var eraseParent := false

onready var frameDuration = 1.0 / fps if fps > 0 else 0.0
var frameTimer: float

# Called when the node enters the scene tree for the first time.
func _ready():
	frameTimer = frameDuration
	velocity.x += random_around(velocity_random.x)
	velocity.y += random_around(velocity_random.y)
	acceleration.x += random_around(acceleration_random.x)
	acceleration.y += random_around(acceleration_random.y)
	
	start_timer()
	
func random_around(val: float) -> float:
	return GlobalData.random.randf_range(-val, val)
	
func start_timer():
	$Timer.start(duration)
	if (eraseParent):
		Utility.print_connect_errors(get_path(), [
			$Timer.connect("timeout", get_parent(), "queue_free")
		])
	else:
		Utility.print_connect_errors(get_path(), [
			$Timer.connect("timeout", self, "queue_free")
		])
	
func _process(delta):
	position += velocity * delta
	velocity += acceleration * delta
	
	if fps > 0:
		frameTimer -= delta
		while frameTimer < 0:
			frame = (frame + 1) % (hframes * vframes)
			frameTimer += frameDuration
