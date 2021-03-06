extends Npc

func _ready():
	$AnimationPlayer.play("ClosedEyes")

func parse_dialogue_signal(signal_name: String):
	$AnimationPlayer.play(signal_name)
