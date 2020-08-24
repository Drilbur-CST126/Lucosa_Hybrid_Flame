extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "on_entered")

func on_entered(other: Node2D):
	if (other.get_class() == "Ruicosa"):
		other.knockback()
