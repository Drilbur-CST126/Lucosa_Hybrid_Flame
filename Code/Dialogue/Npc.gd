extends InteractArea
class_name Npc

const kJumpHeight := 6 * 32.0
const kJumpHorizontalVel := 12.0

export(String, FILE, "*.json") var dialogueTree

var velocity := Vector2.ZERO
var jumping := false

func action():
	if player.is_on_floor():
		var box = GlobalData.hud.show_dialogue_box(dialogueTree)
		Utility.print_errors([
			box.connect("dialogue_signal", self, "parse_dialogue_signal"),
		])

func parse_dialogue_signal(signal_name: String):
	print(signal_name)
	
func _process(delta):
	if jumping:
		velocity.y += GlobalData.gravity * delta
		position += velocity * delta
	
func jump():
	$Graphics/AnimationPlayer.play("JumpStart")
	yield($Graphics/AnimationPlayer, "animation_finished")
	$Graphics/AnimationPlayer.play("Wind")
	z_index -= 3
	
	var jumpTime := sqrt(8.0 * kJumpHeight / (3.0 * GlobalData.gravity))
	var impulse := (2.0 / jumpTime)*(kJumpHeight - GlobalData.gravity * jumpTime * jumpTime / 8.0)
	velocity = Vector2(kJumpHorizontalVel, -impulse)
	jumping = true
	
	yield(Utility.create_timer(self, jumpTime * 3), "timeout")
	queue_free()
	# h(t) = v0*t - g*1/2*t^2
	# h(tm/2) = hm
	# h(tm) = 0
	# v0*tm/2 - g*1/8*tm^2 = hm
	# v0 = 2/tm(hm - g*1/8*tm^2)
	# v0*tm = g*1/2*tm^2
	# 2(hm - g*1/8*tm^2) = g*1/2*tm^2
	# 2hm = g*3/4*tm^2
	# tm = sqrt(8hm\3g)
