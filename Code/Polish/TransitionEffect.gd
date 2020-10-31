extends Node2D

var width: float
var height: float

export(GlobalData.Direction) var direction
export var inverse := false
export var duration: float
export var delay := -1.0

signal finished()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.connect("animation_finished", self, "anim_finished")
	
func anim_finished(_name: String):
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	emit_signal("finished")
	queue_free()
	
func set_dimensions(width_: float, height_: float):
	width = width_
	height = height_
	
func set_direction(direction):
	if direction == GlobalData.Direction.Ltr:
		setup_ltr()
	elif direction == GlobalData.Direction.Rtl:
		setup_rtl()
	elif direction == GlobalData.Direction.Utd:
		setup_utd()
	elif direction == GlobalData.Direction.Dtu:
		setup_dtu()
	elif direction == GlobalData.Direction.Fade:
		setup_fade()
	elif direction == GlobalData.Direction.None:
		call_deferred("anim_finished", "")

func setup_ltr(var followInverse := true):
	if inverse && followInverse:
		setup_rtl(false)
		$AnimationPlayer.play_backwards("Swipe")
	else:
		$ColorRect.margin_left = -width
		$ColorRect.margin_right = 0.0
		$ColorRect.margin_top = 0.0
		$ColorRect.margin_bottom = height
		
		$Transition.region_rect.size.y = height
		$Transition.position.x = 8
		$Transition.position.y = height / 2
		position.x = width
		
		var anim := Animation.new()
		anim.add_track(Animation.TYPE_VALUE)
		anim.length = duration
		anim.track_set_path(0, ".:position:x")
		anim.track_insert_key(0, 0.0, -16.0)
		anim.track_insert_key(0, duration, width)
		$AnimationPlayer.add_animation("Swipe", anim)
		if !inverse:
			$AnimationPlayer.play("Swipe")
		
func setup_rtl(var followInverse := true):
	if inverse && followInverse:
		setup_ltr(false)
		$AnimationPlayer.play_backwards("Swipe")
	else:
		$ColorRect.margin_left = 0.0
		$ColorRect.margin_right = width
		$ColorRect.margin_top = 0.0
		$ColorRect.margin_bottom = height
		
		$Transition.region_rect.size.y = height
		$Transition.position.x = -8.0
		$Transition.position.y = height / 2
		position.x = 0.0
		
		var anim := Animation.new()
		anim.add_track(Animation.TYPE_VALUE)
		anim.length = duration
		anim.track_set_path(0, ".:position:x")
		anim.track_insert_key(0, 0.0, width + 16.0)
		anim.track_insert_key(0, duration, 0.0)
		$AnimationPlayer.add_animation("Swipe", anim)
		if !inverse:
			$AnimationPlayer.play("Swipe")

func setup_utd(var followInverse := true):
	if inverse && followInverse:
		setup_dtu(false)
		$AnimationPlayer.play_backwards("Swipe")
	else:
		$ColorRect.margin_left = 0.0
		$ColorRect.margin_right = width
		$ColorRect.margin_top = -height - 16.0
		$ColorRect.margin_bottom = -16.0
		
		$Transition.region_rect.size.y = width
		$Transition.rotation_degrees = 90
		$Transition.position.x = width / 2
		$Transition.position.y = -8.0
		position.y = height + 16.0
		
		var anim := Animation.new()
		anim.add_track(Animation.TYPE_VALUE)
		anim.length = duration
		anim.track_set_path(0, ".:position:y")
		anim.track_insert_key(0, 0.0, 0.0)
		anim.track_insert_key(0, duration, height + 16.0)
		$AnimationPlayer.add_animation("Swipe", anim)
		if !inverse:
			$AnimationPlayer.play("Swipe")
			
func setup_dtu(var followInverse := true):
	if inverse && followInverse:
		setup_utd(false)
		$AnimationPlayer.play_backwards("Swipe")
	else:
		$ColorRect.margin_left = 0.0
		$ColorRect.margin_right = width
		$ColorRect.margin_top = 0.0
		$ColorRect.margin_bottom = height
		
		$Transition.region_rect.size.y = width
		$Transition.rotation_degrees = -90
		$Transition.position.x = width / 2
		$Transition.position.y = -8.0
		position.y = 0.0
		
		var anim := Animation.new()
		anim.add_track(Animation.TYPE_VALUE)
		anim.length = duration
		anim.track_set_path(0, ".:position:y")
		anim.track_insert_key(0, 0.0, height + 16.0)
		anim.track_insert_key(0, duration, 0.0)
		$AnimationPlayer.add_animation("Swipe", anim)
		if !inverse:
			$AnimationPlayer.play("Swipe")
			
func setup_fade(var followInverse := true):
	$ColorRect.margin_left = 0.0
	$ColorRect.margin_right = width
	$ColorRect.margin_top = 0.0
	$ColorRect.margin_bottom = height
	#$Transition.visible = false
		
	var anim := Animation.new()
	anim.add_track(Animation.TYPE_VALUE)
	anim.length = duration
	anim.track_set_path(0, ".:modulate")
	anim.track_insert_key(0, 0.0, Color(0.0, 0.0, 0.0, 0.0))
	anim.track_insert_key(0, duration, Color(0.0, 0.0, 0.0, 1.0))
	$AnimationPlayer.add_animation("Fade", anim)
	if !inverse:
		modulate = Color(0.0, 0.0, 0.0, 0.0)
		$AnimationPlayer.play("Fade")
	else:
		$AnimationPlayer.play_backwards("Fade")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
