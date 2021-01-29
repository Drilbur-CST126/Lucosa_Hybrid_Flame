extends Node2D
class_name EnemyData

const kFireCol := Color("#ba482f")
const kCorruptCol := Color("#27192f")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var deathShards := 1
export var maxHp := 1
export var vulnerable := true
export var blocking := false
export var pushPlayer := true
export var damageOnTouch := 1
export var flashDur := 0.1
export var colArea: NodePath
export var freeParentOnDeath := true
export var shakeOnDeath := true

var hp: int
var flashTimer := 0.0
var flashMaxDur := 0.0
var flashEffect := false
var flashColor := kFireCol

signal on_death
signal on_hit(source)
signal on_block(source)
signal on_touch(other)
signal on_stop_touch(other)

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = maxHp
	$Area2D.add_child(get_node(colArea).duplicate())
	Utility.print_connect_errors(get_path(), [
		connect("on_death", self, "give_hp_shards"),
		$Area2D.connect("body_entered", self, "on_touch"),
		$Area2D.connect("body_exited", self, "on_stop_touch"),
	])
	if freeParentOnDeath:
		Utility.print_connect_errors(get_path(), [
			connect("on_death", get_parent(), "queue_free")
		])
	
func _process(delta: float):
	if flashEffect:
		var parent := get_parent() as CanvasItem
		parent.modulate = Utility.lerp_color(Color.white, kFireCol, flashTimer / flashMaxDur)
		flashTimer -= delta
		if flashTimer <= 0.0:
			flashEffect = false
			parent.modulate = Color.white
			
func on_touch(other: Node2D):
	if pushPlayer && other.get_class() == GlobalData.kPlayerClassName:
		other.knockback(self, damageOnTouch)
	emit_signal("on_touch", other)
	
func on_stop_touch(other: Node2D):
	emit_signal("on_stop_touch", other)
	
func give_hp_shards():
	GlobalData.hpShards += deathShards

func take_damage(amt: int, source: Node2D):
	if blocking:
		emit_signal("on_block", source)
	else:
		hp -= amt
		flash_color(kFireCol)
		emit_signal("on_hit", source)
		if hp <= 0:
			emit_signal("on_death")
			if shakeOnDeath:
				GlobalData.camera.shake(2.0, 0.1)
				
func flash_color(col: Color, duration := -1.0):
	flashColor = col
	flashEffect = true
	if duration <= 0.0:
		flashTimer = flashDur
	else:
		flashTimer = duration
	flashMaxDur = flashTimer

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
