extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.add_child($CollisionShape2D.duplicate())
	$Area2D.connect("body_entered", self, "on_entered")
	$EnemyData.connect("on_death", self, "queue_free")

func on_entered(other: Node2D):
	if (other.get_class() == "Ruicosa"):
		other.knockback()
