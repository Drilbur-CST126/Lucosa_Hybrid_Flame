tool
extends Node2D

const kLinkLength := 8.0
const kLinkWidth := 2.0

const kChainWideTexture := preload("res://Code/StageAssets/Chain/ChainWide.tres")
const kChainLongTexture := preload("res://Code/StageAssets/Chain/ChainLong.tres")

export(int, 0, 20) var length = 1 setget set_length
export(int, LAYERS_2D_PHYSICS) var layer = 1
export(int, LAYERS_2D_PHYSICS) var mask = 1

var end: RigidBody2D

func set_length(value: int):
	length = value
	update_hit_rect_length()
	
func update_hit_rect_length():
	if Engine.editor_hint && get_node_or_null("HintRect") != null:
		$HintRect.margin_bottom = kLinkLength * length
		
func add_chain_links():
	$StaticBody2D.collision_layer = layer
	$StaticBody2D.collision_mask = mask
	var collisionShape := CollisionShape2D.new()
	var collisionRect := RectangleShape2D.new()
	collisionRect.extents.x = kLinkWidth / 2.0
	collisionRect.extents.y = kLinkLength / 2.0
	collisionShape.shape = collisionRect
	
	var lastBody := $StaticBody2D
	var pinJointPos := 0.0
	for i in range(0, length):
		var rigidBody := RigidBody2D.new()
		rigidBody.add_child(collisionShape.duplicate())
		rigidBody.position.y = kLinkLength * (0.5 + i)
		rigidBody.mass = 20 * (length - i)
		rigidBody.collision_layer = layer
		rigidBody.collision_mask = mask
		add_child(rigidBody)
		
		var pinJoint := PinJoint2D.new()
		pinJoint.position.y = pinJointPos
		pinJointPos = kLinkLength / 2.0
		pinJoint.node_a = lastBody.get_path()
		pinJoint.node_b = rigidBody.get_path()
		pinJoint.bias = length / 600.0
		lastBody.add_child(pinJoint)
		lastBody = rigidBody
		
		var spr := Sprite.new()
		spr.scale = Vector2(1.0 / 12.0, 1.0 / 12.0)
		rigidBody.add_child(spr)
		if i % 2 != 0:
			spr.texture = kChainWideTexture
			rigidBody.show_behind_parent = true
		else:
			spr.texture = kChainLongTexture
		
	end = lastBody
	(end as RigidBody2D).apply_impulse(Vector2.ZERO, Vector2(0.0, 1.0))
	collisionShape.queue_free()
	
func attach_to_end(body: PhysicsBody2D):
	var pinJoint := PinJoint2D.new()
	pinJoint.position.y = kLinkLength / 2.0
	pinJoint.node_a = end.get_path()
	pinJoint.node_b = body.get_path()
	#pinJoint.softness = 0
	end.add_child(pinJoint)
	
func _ready():
	update_hit_rect_length()
	if !Engine.editor_hint:
		add_chain_links()
		$HintRect.queue_free()
