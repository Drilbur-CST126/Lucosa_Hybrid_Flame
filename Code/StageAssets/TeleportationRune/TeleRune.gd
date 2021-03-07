extends InteractArea

export(int, 1, 99) var sequence

var next: InteractArea = null
var active := false setget set_active

func set_active(val: bool):
	if !(val && active): # Don't repeat if it's already active
		active = val
	
		if active:
			if get_parent().has_node(rune_name(sequence - 1)):
				get_parent().get_node(rune_name(sequence - 1)).active = true
			GlobalData.flags.append(active_name())
		
		if get_node_or_null("AnimationPlayer") != null && val:
			$AnimationPlayer.play("Activate")

static func rune_name(seq: int) -> String:
	if seq == 1:
		return "TeleRune"
	else:
		return "TeleRune" + String(seq)

func _ready():
	Utility.print_errors([
		get_parent().connect("ready", self, "on_parent_loaded"),
		$AnimationPlayer.connect("animation_finished", self, "on_anim_finished")
	])
	set_active(GlobalData.flags.has(active_name()))
	if active:
		$AnimationPlayer.play("ActiveIdle")
	else:
		$AnimationPlayer.play("Idle")
	
func on_parent_loaded():
	next = get_parent().get_node_or_null(rune_name(sequence + 1))
	
func on_anim_finished(name: String):
	if name == "Activate":
		$AnimationPlayer.play("ActiveIdle")

func active_name() -> String:
	return String(get_path()) + "_active"

func player_entered(p: Node2D):
	.player_entered(p)
	self.active = true

func action():
	if next != null && next.active:
		next.get_node("Particles2D").emitting = true
		player.global_position = next.global_position
	elif get_parent().has_node(rune_name(1)):
		var node = get_parent().get_node(rune_name(1))
		node.get_node("Particles2D").emitting = true
		player.global_position = node.global_position
	GlobalData.camera.global_position = player.global_position
	$Particles2D.emitting = true
