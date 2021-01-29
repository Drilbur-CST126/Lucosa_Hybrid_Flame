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
			var child := spawn.spawn_enemy()
			Utility.print_connect_errors(get_path(), [
				child.get_node("EnemyData").connect("on_death", self, "on_enemy_defeat")
			])
	
	if numEnemies == 0:
		emit_signal("cleared")
		queue_free()

func _ready():
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
