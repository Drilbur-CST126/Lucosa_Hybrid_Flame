extends Node

enum Direction {Utd, Dtu, Ltr, Rtl, None}

const kPlayerClassName = "Ruicosa"
const kManaRegenPerSec := 20.0
const kMaxMana := 100.0

# Declare member variables here. Examples:
var playerHp := 1 setget set_player_hp
var hpShards := 0 setget set_hp_shards
var playerMaxHp := 5 setget set_player_max_hp
var playerMana := 100.0 setget set_player_mana
var distributeHpShards := true setget set_distribute_hp_shards

var lastRoomId: String
var camera: Node2D
var transDirection = null
var random := RandomNumberGenerator.new()
var lucosaForm := false
var usingController := false

var hasDoubleJump := false
var hasUppercut := false
var hasDive := false
var canTransform := false
var canTransformAnywhere := false setget set_can_transform_anywhere

signal max_hp_changed(maxHp)
signal hp_changed(hp, shards)
signal mana_changed(mana)
signal trans_begin(direction, destination)
signal player_hit(hp)

signal control_config_changed(usingController)

# Called when the node enters the scene tree for the first time.
func _ready():
	#Engine.time_scale = 0.2
	randomize()
	
func set_player_hp(amt: int):
	if amt != playerHp:
		if playerMana as int == 0:
			amt = 0
		var damage = amt < playerHp
		if amt > playerMaxHp:
			amt = playerMaxHp
		playerHp = amt
		if damage:
			hpShards = 0
		emit_signal("hp_changed", playerHp, hpShards)
		
		if playerHp == 0:
			reload_game()
			playerHp = playerMaxHp
		
		if damage:
			emit_signal("player_hit", playerHp)
			get_tree().paused = true
			if camera.has_method("shake"):
				camera.shake(2.0, 0.1)
			yield(get_tree().create_timer(0.2), "timeout")
			get_tree().paused = false
	
func set_hp_shards(amt: int):
	if amt != hpShards:
		distribute_hp_shards(amt)
		
func distribute_hp_shards(amt: int):
	if playerHp != playerMaxHp:
		if distributeHpShards:
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
	
func set_player_mana(amt: float):
	if amt <= 0:
		amt = 0
	if amt > 100:
		amt = 100
	if amt != playerMana:
		if amt == 0:
			camera.shake(1, 0.25)
			get_tree().paused = true
			yield(get_tree().create_timer(0.25), "timeout")
			get_tree().paused = false
		playerMana = amt
		emit_signal("mana_changed", amt)
		
func set_distribute_hp_shards(val: bool):
	distributeHpShards = val
	if val:
		distribute_hp_shards(hpShards)
		
func set_can_transform_anywhere(val: bool):
	canTransformAnywhere = val
	if val:
		canTransform = true
		
func save(room_filename: String):
	var dict := {
		"filename": room_filename,
		"lucosaForm": lucosaForm,
		# Abilities
		"hasDive": hasDive,
		"hasUppercut": hasUppercut,
		"hasDoubleJump": hasDoubleJump,
		"canTransformAnywhere": canTransformAnywhere,
	}
	
	var file = File.new()
	file.open("user://save.json", File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	file.open("user://reload.json", File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	
func save_reload(room_filename: String):
	var dict := {
		"filename": room_filename,
		"lucosaForm": lucosaForm,
		# Abilities
		"hasDive": hasDive,
		"hasUppercut": hasUppercut,
		"hasDoubleJump": hasDoubleJump,
		"canTransformAnywhere": canTransformAnywhere,
	}
	
	var file = File.new()
	file.open("user://reload.json", File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	
func load_file(filename: String):
	var file := File.new()
	file.open(filename, File.READ)
	
	while file.get_position() < file.get_len():
		var data = parse_json(file.get_line())
		
		self.lucosaForm = data["lucosaForm"]
		self.hasDive = data["hasDive"]
		self.hasUppercut = data["hasUppercut"]
		self.hasDoubleJump = data["hasDoubleJump"]
		self.canTransformAnywhere = data["canTransformAnywhere"]
		
		self.lastRoomId = "Savepoint"
		self.transDirection = Direction.Dtu
		get_tree().change_scene(data["filename"])
		save_reload(data["filename"])
	
	file.close()
	
func load_game():
	load_file("user://save.json")
	
func reload_game():
	load_file("user://reload.json")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		#OS.window_fullscreen = !OS.window_fullscreen
		get_tree().change_scene("res://Menu/MainMenu.tscn")
		
#	if Input.is_action_just_pressed("controller_press"):
#		usingController = true
#		emit_signal("control_config_changed", true)
#	if Input.is_action_just_pressed("keyboard_press"):
#		usingController = false
#		emit_signal("control_config_changed", false)
#	if !lucosaForm:
#		self.playerMana += kManaRegenPerSec * delta

func _input(event):
	if event is InputEventKey && usingController:
		usingController = false
		emit_signal("control_config_changed", false)
	elif (event is InputEventJoypadButton || event is InputEventJoypadMotion) \
			&& !usingController:
		usingController = true
		emit_signal("control_config_changed", true)
