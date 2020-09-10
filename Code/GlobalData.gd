extends Node

enum Direction {Utd, Dtu, Ltr, Rtl}

# Declare member variables here. Examples:
var playerHp := 5 setget set_player_hp
var hpShards := 0 setget set_hp_shards
var playerMaxHp := 5 setget set_player_max_hp
var lastRoom: String
var camera: Node2D
var random := RandomNumberGenerator.new()

var hasUppercut := false

signal max_hp_changed(maxHp)
signal hp_changed(hp, shards)
signal trans_begin(direction, destination)

# Called when the node enters the scene tree for the first time.
func _ready():
	#Engine.time_scale = 1.2
	randomize()
	
func set_player_hp(amt: int):
	var damage = amt < playerHp
	if amt > playerMaxHp:
		amt = playerMaxHp
	playerHp = amt
	if damage:
		hpShards = 0
	emit_signal("hp_changed", playerHp, hpShards)
	
	if damage:
		get_tree().paused = true
		if camera.has_method("shake"):
			camera.shake(2.0, 0.1)
		yield(get_tree().create_timer(0.2), "timeout")
		get_tree().paused = false
	
func set_hp_shards(amt: int):
	if playerHp != playerMaxHp:
		while amt >= 5:
			amt -= 5
			playerHp += 1
		hpShards = amt
	else:
		hpShards = 0
	emit_signal("hp_changed", playerHp, hpShards)

func set_player_max_hp(amt: int):
	emit_signal("max_hp_changed", amt)
	playerMaxHp = amt
	
func lerp_color(from: Color, to: Color, val: float):
	return Color(lerp(from.r, to.r, val), \
			lerp(from.g, to.g, val), \
			lerp(from.b, to.b, val), \
			lerp(from.a, to.a, val))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		OS.window_fullscreen = !OS.window_fullscreen
