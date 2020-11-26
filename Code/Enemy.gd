extends Node2D


const fireCol := Color("#ba482f")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var deathShards := 1
export var maxHp := 1
export var vulnerable := true
export var blocking := false
export var pushPlayer := true
export var damageOnTouch := 1
export var fireFlashDur := 0.1
export var colArea: NodePath
export var freeParentOnDeath := true

var hp: int
var fireTimer := 0.0
var fireFlashEffect := false

signal on_death
signal on_hit
signal on_block
signal on_touch(other)

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = maxHp
	connect("on_death", self, "give_hp_shards")
	$Area2D.add_child(get_node(colArea).duplicate())
	$Area2D.connect("body_entered", self, "on_touch")
	if freeParentOnDeath:
		connect("on_death", get_parent(), "queue_free")
	
func _process(delta: float):
	if fireFlashEffect:
		var parent := get_parent() as CanvasItem
		parent.modulate = Utility.lerp_color(Color.white, fireCol, fireTimer/ fireFlashDur)
		fireTimer -= delta
		if fireTimer <= 0.0:
			fireFlashEffect = false
			parent.modulate = Color.white
			
func on_touch(other: Node2D):
	if pushPlayer && other.get_class() == GlobalData.kPlayerClassName:
		other.knockback(self, damageOnTouch)
	emit_signal("on_touch", other)
	
func give_hp_shards():
	GlobalData.hpShards += deathShards

func take_damage(amt: int):
	if blocking:
		emit_signal("on_block")
	else:
		hp -= amt
		fireTimer = fireFlashDur
		fireFlashEffect = true
		emit_signal("on_hit")
		if hp <= 0:
			emit_signal("on_death")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
