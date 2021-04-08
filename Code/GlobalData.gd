extends Node

enum Direction {Utd, Dtu, Ltr, Rtl, Fade, None}

enum Ability {Dive, Uppercut, DoubleJump, Fireball, ExplosionImmunity, TransformAnywhere}

const kPlayerClassName = "Ruicosa"
const kManaRegenPerSec := 10.0
const kMaxMana := 100.0

var debug := true

var playerHp := 4 setget set_player_hp
var hpShards := 0 setget set_hp_shards
var playerMaxHp := 4 setget set_player_max_hp
var playerMana := 100.0 setget set_player_mana
var charges := 0 setget set_charges
var maxCharges := 0 setget set_max_charges
var chargeEnabled := true setget set_charge_enabled
var playerAttackDmg := 2
var playerForesight := 0
var distributeHpShards := true setget set_distribute_hp_shards
var gravity: float

var lastRoomId: String
var camera: DynamicCamera
var player: Node2D
var curRoom := 1
var roomsVisited := [1, 2, 3, 4, 5]
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
signal charges_changed(charges)
signal max_charges_changed(charges)
signal charge_enabled_changed(state)
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
	set_player_hp(amt)
	
func set_player_mana(amt: float):
	if amt <= 0:
		amt = 0
	if amt > kMaxMana:
		amt = 0
		set_charges(charges + 1)
	if amt != playerMana:
		playerMana = amt
		emit_signal("mana_changed", amt)
		
func set_charge_enabled(val: bool):
	chargeEnabled = val
	emit_signal("charge_enabled_changed", val)
		
func set_charges(amt: int):
	if amt <= 0:
		amt = 0
	elif amt > maxCharges:
		amt = maxCharges
		
	if amt != charges:
		charges = amt
		emit_signal("charges_changed", amt)
		
func set_max_charges(amt: int):
	if amt != maxCharges:
		maxCharges = amt
		emit_signal("max_charges_changed", amt)
		
func set_distribute_hp_shards(val: bool):
	distributeHpShards = val
	if val:
		distribute_hp_shards(hpShards)
		
func set_can_transform_anywhere(val: bool):
	canTransformAnywhere = val
	if val:
		canTransform = true
		
func player_at_full_hp() -> bool:
	var hpFromShards := int(hpShards / 5.0)
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
		"hasExplosionImmunity": hasExplosionImmunity,
		"canTransformAnywhere": canTransformAnywhere,
		"flags": flags,
		# Stats
		"maxHp": playerMaxHp,
		"attackDmg": playerAttackDmg,
		"maxCharges": maxCharges,
		"foresight": playerForesight,
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
		"hasExplosionImmunity": hasExplosionImmunity,
		"canTransformAnywhere": canTransformAnywhere,
		"flags": flags,
		# Stats
		"maxHp": playerMaxHp,
		"attackDmg": playerAttackDmg,
		"maxCharges": maxCharges,
		"foresight": playerForesight,
	}
	
	var file = File.new()
	file.open("user://reload.json", File.WRITE)
	file.store_line(to_json(dict))
	file.close()
	#file.free()
	
func load_file(filename: String):
	var file := File.new()
	var fileOpen := file.open(filename, File.READ)
	
	if fileOpen == 0:
		var saveLocation: String
		
		while file.get_position() < file.get_len():
			var data = parse_json(file.get_line())
			
			self.flags += data["flags"]
			self.lucosaForm = data["lucosaForm"]
			self.hasDive = hasDive || data["hasDive"]
			self.hasUppercut = hasUppercut || data["hasUppercut"]
			self.hasDoubleJump = hasDoubleJump || data["hasDoubleJump"]
			self.hasFireball = hasFireball || data["hasFireball"]
			self.hasExplosionImmunity = hasExplosionImmunity || data["hasExplosionImmunity"]
			self.canTransformAnywhere = canTransformAnywhere || data["canTransformAnywhere"]
			self.playerMaxHp = int(max(playerMaxHp, data["maxHp"]))
			self.playerAttackDmg = int(max(playerAttackDmg, data["attackDmg"]))
			self.maxCharges = int(max(maxCharges, data["maxCharges"]))
			self.charges = maxCharges
			self.playerForesight = int(max(playerForesight, data["foresight"]))
			
			self.lastRoomId = "Savepoint"
			self.transDirection = Direction.Fade
			Utility.print_errors([
				get_tree().change_scene(data["filename"]),
			])
			saveLocation = data["filename"]
		
		file.close()
		save_reload(saveLocation)
		return 0
	else:
		return fileOpen
	
func load_game() -> bool:
	return load_file("user://save.json") == 0
	
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
		Ability.ExplosionImmunity:
			return hasExplosionImmunity
		Ability.TransformAnywhere:
			return canTransformAnywhere
	return false
	
func transition_rooms(dir, dest: String, curRoomId: String):
	transDirection = dir
	lastRoomId = curRoomId
	emit_signal("trans_begin", dir, dest)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_just_pressed("menu"):
#		OS.window_fullscreen = !OS.window_fullscreen
#		#print_stray_nodes()
	
	if regenMana && charges < maxCharges:
		set_player_mana(playerMana + kManaRegenPerSec * delta)
	elif playerMana != 0:
		set_player_mana(0)

func _input(event):
	if event is InputEventKey && usingController:
		usingController = false
		emit_signal("control_config_changed", false)
	elif (event is InputEventJoypadButton || event is InputEventJoypadMotion) \
			&& !usingController:
		usingController = true
		emit_signal("control_config_changed", true)
		
	if debug && event is InputEventKey && event.pressed && !event.echo:
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
			KEY_5:
				hasExplosionImmunity = !hasExplosionImmunity
				print("Explosion immunity has been set to " + String(hasExplosionImmunity))
			KEY_6:
				canTransformAnywhere = !canTransformAnywhere
				canTransform = canTransformAnywhere
				print("Can transform anywhere has been set to " + String(canTransformAnywhere))
			KEY_7:
				GlobalData.playerMaxHp += 1
				print("Extra HP granted")
			KEY_8:
				GlobalData.maxCharges += 1
				print("Extra Charge granted")
			KEY_9:
				GlobalData.playerForesight += 1
				print("Extra Power Orb granted")
			KEY_0:
				Engine.time_scale = 0.2
			KEY_SHIFT:
				set_player_hp(playerMaxHp)
			KEY_TAB:
				hasDive = true
				hasUppercut = true
				hasDoubleJump = true
				hasFireball = true
				hasExplosionImmunity = true
				canTransformAnywhere = true
				canTransform = true
				print("All upgrades turned on")
