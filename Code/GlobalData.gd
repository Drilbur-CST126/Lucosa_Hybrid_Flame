extends Node

enum Direction {Utd, Dtu, Ltr, Rtl, Fade, None}

enum Ability {Dive, Uppercut, DoubleJump, Fireball, TransformAnywhere}

const kPlayerClassName = "Ruicosa"
const kManaRegenPerSec := 15.0
const kMaxMana := 100.0

var debug := true

var playerHp := 5 setget set_player_hp
var hpShards := 0 setget set_hp_shards
var playerMaxHp := 5 setget set_player_max_hp
var playerMana := 100.0 setget set_player_mana
var distributeHpShards := true setget set_distribute_hp_shards
var gravity: float

var lastRoomId: String
var camera: DynamicCamera
var oldCameraLimits = null
var transDirection = null
var random := RandomNumberGenerator.new()
var lucosaForm := false
var usingController := false
var regenMana := true
var hud: CanvasLayer
var flags := []

var hasDoubleJump := false
var hasUppercut := false
var hasDive := false
var hasFireball := false
var hasExplosionImmunity := false
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
				camera.shake(3.0, 0.15)
			yield(get_tree().create_timer(0.2), "timeout")
			if playerHp <= 0:
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
		"hasFireball": hasFireball,
		"canTransformAnywhere": canTransformAnywhere,
		"flags": flags
	}
	
	var file = File.new()
	file.open("user://save.json", File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	file.open("user://reload.json", File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	#file.free()
	
func save_reload(room_filename: String):
	var dict := {
		"filename": room_filename,
		"lucosaForm": lucosaForm,
		# Abilities
		"hasDive": hasDive,
		"hasUppercut": hasUppercut,
		"hasDoubleJump": hasDoubleJump,
		"hasFireball": hasFireball,
		"canTransformAnywhere": canTransformAnywhere,
		"flags": flags
	}
	
	var file = File.new()
	file.open("user://reload.json", File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	#file.free()
	
func load_file(filename: String):
	var file := File.new()
	file.open(filename, File.READ)
	
	var saveLocation: String
	
	while file.get_position() < file.get_len():
		var data = parse_json(file.get_line())
		
		self.flags = Array(data["flags"])
		self.lucosaForm = data["lucosaForm"]
		self.hasDive = hasDive || data["hasDive"]
		self.hasUppercut = hasUppercut || data["hasUppercut"]
		self.hasDoubleJump = hasDoubleJump || data["hasDoubleJump"]
		self.hasFireball = hasFireball || data["hasFireball"]
		self.canTransformAnywhere = canTransformAnywhere || data["canTransformAnywhere"]
		
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
	
func unlock_ability(ability):
	match ability:
		Ability.Dive:
			hasDive = true
		Ability.Uppercut:
			hasUppercut = true
		Ability.DoubleJump:
			hasDoubleJump = true
		Ability.Fireball:
			hasFireball = true
		Ability.TransformAnywhere:
			canTransformAnywhere = true
	emit_signal("ability_unlocked", ability)
			
func has_ability(ability) -> bool:
	match ability:
		Ability.Dive:
			return hasDive
		Ability.Uppercut:
			return hasUppercut
		Ability.DoubleJump:
			return hasDoubleJump
		Ability.Fireball:
			return hasFireball
		Ability.TransformAnywhere:
			return canTransformAnywhere
	return false
	
func transition_rooms(dir, dest: String, curRoomId: String):
	transDirection = dir
	lastRoomId = curRoomId
	emit_signal("trans_begin", dir, dest)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		#OS.window_fullscreen = !OS.window_fullscreen
		print_stray_nodes()
	
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
		
func _unhandled_key_input(event):
	if debug && event is InputEventKey:
		if event.scancode >= KEY_0 && event.scancode <= KEY_9 && event.pressed && !event.echo:
			match event.scancode:
				KEY_1:
					hasDive = !hasDive
					print("Dive has been set to " + String(hasDive))
				KEY_2:
					hasUppercut = !hasUppercut
					print("Uppercut has been set to " + String(hasUppercut))
				KEY_3:
					hasDoubleJump = !hasDoubleJump
					print("Double jump has been set to " + String(hasDoubleJump))
				KEY_4:
					hasFireball = !hasFireball
					print("Fireball has been set to " + String(hasFireball))
				KEY_6:
					canTransformAnywhere = !canTransformAnywhere
					canTransform = canTransformAnywhere
					print("Can transform anywhere has been set to " + String(canTransformAnywhere))
