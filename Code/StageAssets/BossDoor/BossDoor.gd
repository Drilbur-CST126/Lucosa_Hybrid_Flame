extends StaticBody2D

export var defaultClosed := true

func _ready():
	if !defaultClosed:
		open()
	else:
		close()

func open():
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play_backwards("close")
	
func close():
	$CollisionShape2D.set_deferred("disabled", false)
	$AnimationPlayer.play("close")
