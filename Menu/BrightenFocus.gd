extends ColorRect


func _ready():
	var parent := get_parent() as Control
	Utility.print_errors([
		parent.connect("focus_entered", self, "show"),
		parent.connect("focus_exited", self, "hide"),
	])
	hide()
