extends Node

enum Direction {Utd, Dtu, Ltr, Rtl, Fade, None}

const kPlayerClassName = "Ruicosa"
const kManaRegenPerSec := 15.0
const kMaxMana := 100.0

# Declare member variables here. Examples:
var playerHp := 5 setget set_player_hp
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
var regenMana := true

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
signal hit_animation_finished()
signal player_dead()

signal control_config_changed(usingController)

# Called when the node enters the scene tree for the first time.
func _ready():
	#Engine.time_scale = 0.2
	randomize()
	random.randomize()
	
func set_player_hp(amt: int):
	if amt != playerHp:
		var damage = amt < playerHp
		if amt > playerMaxHp:
			amt = playerMaxHp
		playerHp = amt
		if damage:
			hpShards = 0
		emit_signal("hp_changed", playerHp, hpShards)
		
		if damage:
			emit_signal("player_hit", playerHp)
			get_tree().paused = true
			if camera.has_method("shake"):
				camera.shake(2.0, 0.1)
			yield(get_tree().create_timer(0.2), "timeout")
			if playerHp == 0:
				if camera.has_method("shake"):
					camera.shake(4.0, -1)
				yield(get_tree().create_timer(1.0), "timeout")
				emit_signal("player_dead")
			else:
				get_tree().paused = false
				emit_signal("hit_animation_finished")
	
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
	if amt > kMaxMana:
		amt = kMaxMana
	if amt != playerMana:
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
		
func player_at_full_hp() -> bool:
	var hpFromShards := hpShards / 5
	return hpFromShards + playerHp >= playerMaxHp
		
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
	
	var saveLocation: String
	
	while file.get_position() < file.get_len():
		var data = parse_json(file.get_line())
		
		self.lucosaForm = data["lucosaForm"]
		self.hasDive = data["hasDive"]
		self.hasUppercut = data["hasUppercut"]
		self.hasDoubleJump = data["hasDoubleJump"]
		self.canTransformAnywhere = data["canTransformAnywhere"]
		
		self.lastRoomId = "Savepoint"
		self.transDirection = Direction.Fade
		get_tree().change_scene(data["filename"])
		saveLocation = data["filename"]
	
	file.close()
	save_reload(saveLocation)
	
func load_game():
	load_file("user://save.json")
	
func reload_game():
	load_file("user://reload.json")
	playerHp = playerMaxHp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		#OS.window_fullscreen = !OS.window_fullscreen
		get_tree().change_scene("res://Menu/MainMenu.tscn")
	
	if regenMana:
		set_player_mana(playerMana + kManaRegenPerSec * delta)

func _input(event):
	if event is InputEventKey && usingController:
		usingController = false
		emit_signal("control_config_changed", false)
	elif (event is InputEventJoypadButton || event is InputEventJoypadMotion) \
			&& !usingController:
		usingController = true
		emit_signal("control_config_changed", true)
