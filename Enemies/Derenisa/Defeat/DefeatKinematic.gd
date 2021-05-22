extends KinematicBody2D

const DefeatNpc := preload("res://Enemies/Derenisa/Defeat/DefeatNpc.tscn")

var velocity: Vector2

func _ready():
	pass

func _physics_process(delta):
	velocity.y += GlobalData.gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		var npc := DefeatNpc.instance() as Npc
		get_parent().add_child_below_node(self, npc)
		npc.scale = self.scale
		npc.global_position = self.global_position
		queue_free()
