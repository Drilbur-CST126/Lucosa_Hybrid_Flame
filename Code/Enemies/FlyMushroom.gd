extends KinematicBody2D


const motionRange := 3.0
const animDur := 0.6

onready var initialY := position.y
var animPos := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#$EnemyData.connect("on_death", self, "queue_free")

func _physics_process(delta: float):
	animPos += delta
	while animPos > animDur:
		animPos -= animDur
	position.y = initialY + motionRange / 2.0 * sin(2 * PI * animPos / animDur)
