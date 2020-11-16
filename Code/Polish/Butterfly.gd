extends AnimatedSprite

const kMaxFlapTime := 3.5
const kMinFlapTime := 0.5

func start_timer():
	play("default")
	$FlapTimer.start(GlobalData.random.randf_range(kMinFlapTime, kMaxFlapTime))

func flap():
	play("Flap")
	
func anim_finish():
	if animation == "Flap":
		start_timer()

# Called when the node enters the scene tree for the first time.
func _ready():
	Utility.print_connect_errors(get_path(), [
		$FlapTimer.connect("timeout", self, "flap"),
		connect("animation_finished", self, "anim_finish")
	])
	start_timer()
	if rotation == 0.0:
		rotation_degrees = GlobalData.random.randf_range(-15.0, 15.0)
	(get_parent() as KinematicBody2D).move_and_slide(Vector2.ZERO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
