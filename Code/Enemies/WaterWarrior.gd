extends KinematicBody2D

export var target: NodePath

var attacking := false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var _err = $EnemyData.connect("on_death", self, "_die")
	$KnockbackArea.add_child($CollisionShape2D.duplicate())
	_err = $KnockbackArea.connect("body_entered", self, "_knockback")
	_err = $EnemyData.connect("on_block", self, "_begin_attack")
	_err = $AttackWindup.connect("timeout", self, "_attack")
	_err = $AttackHold.connect("timeout", self, "_end_attack")
	
func _process(_delta):
	if !attacking && get_node_or_null(target) != null:
		var targetNode := get_node(target)
		if targetNode.position.x > position.x:
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false

func _die():
	queue_free()
	
func _begin_attack():
	attacking = true
	$EnemyData.blocking = false
	$AttackWindup.start()
	$AttackHold.stop()
	
func _attack():
	$AnimatedSprite.play("attack")
	$AttackHold.start()
	
func _end_attack():
	attacking = false
	$AnimatedSprite.play("default")
	$EnemyData.blocking = true
	
func _knockback(entity: Node):
	if entity.get_class() == "Toxen":
		entity.knockback()
		_begin_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
