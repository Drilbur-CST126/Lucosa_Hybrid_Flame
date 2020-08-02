extends Node2D

var width := ProjectSettings.get_setting("display/window/size/width") as int
var height := ProjectSettings.get_setting("display/window/size/height") as int

export(GlobalData.Direction) var direction
export var inward := false
export var duration: float

signal finished()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.connect("animation_finished", self, "emit_signal", ["finished"])
	setup_ltr()

func setup_ltr():
	$ColorRect.margin_left = -width
	$ColorRect.margin_right = 0.0
	$ColorRect.margin_top = 0.0
	$ColorRect.margin_bottom = height
	
	$Transition.region_rect.size.y = height
	$Transition.position.x = 8
	$Transition.position.y = height / 2
	
	var anim := Animation.new()
	anim.add_track(Animation.TYPE_VALUE)
	anim.length = duration
	anim.track_set_path(0, ".:position:x")
	anim.track_insert_key(0, 0.0, -16.0)
	anim.track_insert_key(0, duration, width)
	$AnimationPlayer.add_animation("Swipe", anim)
	$AnimationPlayer.play("Swipe")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
