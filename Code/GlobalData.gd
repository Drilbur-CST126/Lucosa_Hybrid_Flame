extends Node

enum Direction {Utd, Dtu, Ltr, Rtl}

# Declare member variables here. Examples:
var playerHp := 5 setget set_player_hp
var hpShards := 0 setget set_hp_shards
var playerMaxHp := 5 setget set_player_max_hp
var lastRoom: String

var hasUppercut := false

signal max_hp_changed(maxHp)
signal hp_changed(hp, shards, broken)
signal trans_begin(direction, destination)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_player_hp(amt: int):
	if amt > playerMaxHp:
		amt = playerMaxHp
	playerHp = amt
	emit_signal("hp_changed", playerHp, hpShards, 0)
	
func set_hp_shards(amt: int):
	if playerHp != playerMaxHp:
		while amt >= 5:
			amt -= 5
			playerHp += 1
		hpShards = amt
	else:
		hpShards = 0
	emit_signal("hp_changed", playerHp, hpShards, 0)

func set_player_max_hp(amt: int):
	emit_signal("max_hp_changed", amt)
	playerMaxHp = amt

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
