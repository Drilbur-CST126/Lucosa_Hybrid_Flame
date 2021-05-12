extends Control

const HealMarker = preload("res://Code/HealMinigame/HealMarker.tscn")
const kMaxRuns := 5

export var leftPosition := 40.0
export var rightPosition := 1240.0

var runsLeft := kMaxRuns setget set_runs_left

signal on_finish()

func set_runs_left(val: int):
	runsLeft = val
	for i in range($ChargesRemaining.get_child_count()):
		var child: CanvasItem = $ChargesRemaining.get_child(i)
		if i > val:
			child.hide()
		else:
			child.show()

func begin_run():
	if runsLeft > 0:
		var onLeft := (runsLeft % 2 == 1)
		var marker := HealMarker.instance()
		if onLeft:
			marker.startPosition = leftPosition
			marker.endPosition = rightPosition
		else:
			marker.startPosition = rightPosition
			marker.endPosition = leftPosition
		marker.position.y = 330
		add_child(marker)
		Utility.print_connect_errors(get_path(), [
			marker.connect("on_submit", self, "on_submit")
		])
		self.runsLeft -= 1
	else:
		finish()
		
func finish():
	emit_signal("on_finish")
	$AnimationPlayer.play("FadeOut")
		
func on_anim_finished(name: String):
	if name == "FadeIn":
		begin_run()
	else:
		queue_free()
	
func on_submit(amt: int):
	GlobalData.hpShards += amt
	if GlobalData.player_at_full_hp():
		finish()
	else:
		begin_run()

func _ready():
	Utility.print_connect_errors(get_path(), [
		$AnimationPlayer.connect("animation_finished", self, "on_anim_finished")
	])
	
func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		finish()
