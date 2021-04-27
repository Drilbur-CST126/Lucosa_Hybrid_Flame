extends Node2D

var arenaSpawns: Array
var numEnemies: int
var numDefeated := 0

signal cleared()

func on_enemy_defeat():
	numEnemies -= 1
	numDefeated += 1
	
	for i in arenaSpawns:
		var spawn := i as ArenaSpawn
		spawn.enemiesRequired -= 1
		if spawn.enemiesRequired == 0:
			spawn_enemy(spawn)
	
	if numEnemies == 0:
		clear()
		
func spawn_enemy(spawn: ArenaSpawn):
	var child := spawn.spawn_enemy()
	Utility.print_connect_errors(get_path(), [
		child.get_node("EnemyData").connect("on_death", self, "on_enemy_defeat")
	])
		
func get_clear_str() -> String:
	return String(get_path()) + "_cleared"
		
func clear():
	emit_signal("cleared")
	queue_free()
	GlobalData.flags.append(get_clear_str())

func _ready():
	if GlobalData.flags.has(get_clear_str()):
		clear()
	
	for i in get_children():
		var child := i as Node2D
		var isArenaSpawn := child is ArenaSpawn
		if child.has_node("EnemyData") or isArenaSpawn:
			numEnemies += 1
			if isArenaSpawn:
				arenaSpawns.append(child)
			else:
				Utility.print_connect_errors(get_path(), [
					child.get_node("EnemyData").connect("on_death", self, "on_enemy_defeat")
				])
				
func signal_start():
	for i in arenaSpawns:
		var spawn := i as ArenaSpawn
		if spawn.enemiesRequired == 0:
			spawn_enemy(spawn)
