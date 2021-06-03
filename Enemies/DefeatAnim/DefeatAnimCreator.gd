extends Node2D

const DefeatAnim := preload("res://Enemies/DefeatAnim/DefeatAnim.tscn")

export var texture: Texture
export var enemyDataPath := NodePath("../EnemyData")

func _ready():
	var enData := get_node_or_null(enemyDataPath)
	if enData != null && enData is EnemyData:
		Utility.print_errors([
			(enData as EnemyData).connect("on_death", self, "create"),
		])
		
func create():
	var anim := DefeatAnim.instance() as Node2D
	anim.get_node("Sprite").texture = texture
	var parent := get_parent()
	parent.get_parent().add_child_below_node(parent, anim)
	anim.global_position = global_position
	anim.scale.x = Utility.get_dir(GlobalData.player.global_position < global_position)
