tool
extends Node2D

const kDiveImpulse := 1536.0

export(int, 0, 15) var length = 1 setget set_length

var awaitDive := false

func set_length(value: int):
	length = value
	update_chain_length()

func update_chain_length():
	if get_node_or_null("Chain") != null:
		$Chain.length = 2 * length
		$RigidBody2D.position.y = 12.0 + 2 * $Chain.kLinkLength * length
		
func contact(other: Node2D):
	if other is Ruicosa:
		if other.state == other.ActionState.Dive:
			on_dive_contact(other)
		else:
			awaitDive = true
			Utility.print_connect_errors(get_path(), [
				other.connect("dive", self, "on_dive_contact"),
			])
			
func on_stop_contact(other: Node2D):
	if other is Ruicosa && awaitDive:
		other.disconnect("dive", self, "on_dive_contact")
		awaitDive = false
			
func on_dive_contact(other: Node2D):
	other.knockback($RigidBody2D/EnemyData, 0)
	on_hit(other)
	
func on_hit(source: Node2D):
	var playerOfs: Vector2 = source.global_position - $RigidBody2D.global_position
	$RigidBody2D.apply_impulse(playerOfs, playerOfs.normalized() * -kDiveImpulse)

func _ready():
	update_chain_length()
	if !Engine.editor_hint:
		$Chain.attach_to_end($RigidBody2D)
		Utility.print_connect_errors(get_path(), [
			$RigidBody2D/EnemyData.connect("on_touch", self, "contact"),
			$RigidBody2D/EnemyData.connect("on_stop_touch", self, "on_stop_contact"),
			$RigidBody2D/EnemyData.connect("on_block", self, "on_hit"),
		])
