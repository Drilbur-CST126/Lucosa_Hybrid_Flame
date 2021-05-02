extends PlayerArea

const kVelocity := 256.0
const kDistance := 320.0 * 0.75

export var movingRight := false

var distanceTravelled := 0.0

func _ready():
	var dir := Utility.get_dir(!movingRight)
	scale.x = dir

func player_entered(pNode: Node2D):
	var player := pNode as Ruicosa
	player.knockback(null, 1)

func _physics_process(delta: float):
	var moveAmt := delta * kVelocity
	position.x += Utility.get_dir(movingRight) * moveAmt
	distanceTravelled += moveAmt
	if distanceTravelled >= kDistance:
		queue_free()
