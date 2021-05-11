extends KinematicBody2D

export var target: NodePath
export var walkVelocity := 160.0
export var velocity := Vector2(0.0, 0.0)
export var gravity := 128.0
export var moving := true

var attacking := false

func set_flip(flip: bool):
	$AnimatedSprite.flip_h = flip
	$AnimatedSprite.offset.x = 2 if flip else -2
	
func look_at_target():
	var targetNode := get_node_or_null(target)
	if targetNode != null:
		set_flip(targetNode.position.x > position.x)

# Called when the node enters the scene tree for the first time.
func _ready():
	if !moving:
		walkVelocity = 0.0
	velocity.x = walkVelocity
	var _err #= $EnemyData.connect("on_death", self, "_die")
	_err = $EnemyData.connect("on_touch", self, "knockback")
	_err = $EnemyData.connect("on_block", self, "_begin_attack")
	_err = $AttackWindup.connect("timeout", self, "_attack")
	_err = $AttackHold.connect("timeout", self, "_end_attack")
			
func _process(_delta):
	if !moving && !attacking:
		look_at_target()
			
func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.y = move_and_slide(Vector2((velocity.x * (1 if $AnimatedSprite.flip_h else -1)) as int, velocity.y),
			Vector2.UP, false).y
	if is_on_wall() and !attacking:
		set_flip(!$AnimatedSprite.flip_h)
	
func _begin_attack(_src = null):
	if !attacking:
		attacking = true
		$EnemyData.blocking = false
		$AttackWindup.start()
		$AttackHold.stop()
		$AnimationPlayer.play("Knockback")
		look_at_target()
	
func _attack():
	$AnimatedSprite.play("attack")
	$AttackHold.start()
	$AnimationPlayer.play("Thrust")
	
func _end_attack():
	attacking = false
	$AnimatedSprite.play("default")
	$EnemyData.blocking = true
	velocity.x = walkVelocity
	
func knockback(entity: Node):
	if entity.get_class() == "Ruicosa" && !$AnimatedSprite.animation == "attack":
		_begin_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
