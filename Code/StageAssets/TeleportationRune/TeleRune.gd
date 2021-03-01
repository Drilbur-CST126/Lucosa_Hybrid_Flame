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
		
		if get_node_or_null("ColorRect") != null:
			if active:
				$ColorRect.color = Color.white
			else:
				$ColorRect.color = Color.gray

static func rune_name(seq: int) -> String:
	if seq == 1:
		return "TeleRune"
	else:
		return "TeleRune" + String(seq)

func _ready():
	Utility.print_errors([
		get_parent().connect("ready", self, "on_parent_loaded"),
	])
	set_active(GlobalData.flags.has(active_name()))
	
func on_parent_loaded():
	next = get_parent().get_node_or_null(rune_name(sequence + 1))

func active_name() -> String:
	return String(get_path()) + "_active"

func player_entered(p: Node2D):
	.player_entered(p)
	self.active = true

func action():
	if next != null && next.active:
		player.global_position = next.global_position
	elif get_parent().has_node(rune_name(1)):
		player.global_position = get_parent().get_node(rune_name(1)).global_position
