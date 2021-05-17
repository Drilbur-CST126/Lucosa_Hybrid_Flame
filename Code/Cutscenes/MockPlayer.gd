extends KinematicBody2D
class_name MockPlayer

# These variables are treated like const
var kJumpImpulse: float
var kWalkSpeed: float
var kRunSpeed: float
var kAnimOffsets: Dictionary

var facingRight := true setget set_facing_right
var velocity := Vector2.ZERO
var running := false
var lucosaForm := false setget set_form
var dest = null# Vector2

signal destination_reached()
signal animation_finished()

func set_facing_right(value: bool):
	facingRight = value
	$Sprite.flip_h = value
	$Sprite.offset.x = kAnimOffsets[$Sprite.animation]
	$Sprite.offset.x *= -1 if facingRight else 1
	
func set_form(value: bool):
	lucosaForm = value
	play_anim(get_anim())

func play_anim(anim: String, reset := false):
	if lucosaForm:
		anim = "Lucosa_" + anim
		
	if !kAnimOffsets.has(anim):
		play_anim("Idle")
	else:
		if reset && $Sprite.animation == anim:
			$Sprite.frame = 0
		else:
			$Sprite.play(anim)
			$Sprite.offset.x = kAnimOffsets[anim]
			$Sprite.offset.x *= -1 if facingRight else 1
			
func get_anim() -> String:
	if lucosaForm:
		return $Sprite.animation.split("_")[0]
	return $Sprite.animation
	
func on_anim_finished():
	emit_signal("animation_finished")

func jump():
	velocity.y = kJumpImpulse

func move_to(globalPos: float, runToPos: bool):
	dest = globalPos
	running = runToPos
	play_anim("Run")

func _ready():
	Utility.print_errors([
		$Sprite.connect("animation_finished", self, "on_anim_finished"),
	])

func _process(delta):
	velocity.y += GlobalData.gravity * delta
	
	if dest != null:
		self.facingRight = dest as float > global_position.x
		var dir := Utility.get_dir(facingRight)
		velocity.x = (kRunSpeed if running else kWalkSpeed) * dir
		if dir * (position.x + velocity.x * delta) > dir * dest:
			velocity.x = (dest - position.x) * delta
			dest = null
			emit_signal("destination_reached")
	else:
		velocity.x = 0.0
			
	velocity = move_and_slide(velocity, Vector2.UP, true)
