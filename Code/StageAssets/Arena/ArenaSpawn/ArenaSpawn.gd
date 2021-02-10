extends Node2D
class_name ArenaSpawn

export(int, 1, 99) var enemiesRequired := 1
export(String, FILE, "*.tscn,*.scn") var spawn := ""

var kEnemy: PackedScene
var child: Node2D

func _ready():
	$Circle.scale = Vector2.ZERO
	$Sprite.scale = Vector2.ZERO
	kEnemy = load(spawn) 
	Utility.print_connect_errors(get_path(), [
		$AnimationPlayer.connect("animation_finished", self, "anim_finished"),
	])

func spawn_enemy() -> Node2D:
	child = kEnemy.instance() as Node2D
	child.global_position = global_position
	$AnimationPlayer.play("Summon")
	return child

func anim_finished(_name):
	get_parent().call_deferred("add_child", child)
	$Particles2D.emitting = true
#	var part := $Particles2D
#	remove_child($Particles2D)
#	child.add_child(part)
	
	var en := child.get_node("EnemyData") as EnemyData
	en.flash_color(en.kCorruptCol)
	
	child = null
	
func _process(_delta):
	if get_node_or_null("Particles2D") != null && $Particles2D.emitting && !$Particles2D/VisibilityNotifier2D.is_on_screen():
		$Particles2D.queue_free()
	
func _exit_tree():
	if child != null: # If scene is exited before the spawn anim finishes
		child.queue_free()
