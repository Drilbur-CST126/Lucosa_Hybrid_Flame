extends Node2D

export var endPosition: float
export var startPosition: float
export var secondsToEnd := 1.5

var duration := 0.0

signal on_submit(amt)

func submit():
	$RayCast.enabled = true
	$RayCast.force_raycast_update()
	var obj := $RayCast.get_collider() as Object
	var amt := 1
	
	if obj != null && obj.get_class() == "HealthRegion":
		amt = obj.shards
	emit_signal("on_submit", amt)
	
	queue_free()
	
func _ready():
	position.x = startPosition

func _process(_delta: float):
	if Input.is_action_just_pressed("spell"):
		submit()

func _physics_process(delta: float):
	position.x = lerp(startPosition, endPosition, duration / secondsToEnd)
	duration += delta
	if duration >= secondsToEnd:
		submit()
