extends Node2D

const Health = preload("res://Code/Health.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var curNumHearts := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalData.connect("max_hp_changed", self, "_adjust_max_hp_display")
	GlobalData.connect("hp_changed", self, "_adjust_hp_display")
	_adjust_max_hp_display(GlobalData.playerMaxHp)
	
func _adjust_max_hp_display(maxHp: int):
	$Background.margin_right = 3 + (12 * maxHp)
	if curNumHearts < maxHp:
		for i in range(maxHp - curNumHearts):
			var heart := Health.instance()
			heart.offset.x = 7 + (12 * (i + curNumHearts))
			$Hearts.add_child(heart)
	
	curNumHearts = maxHp
	_adjust_hp_display(GlobalData.playerHp, GlobalData.hpShards, 0)

func _adjust_hp_display(hp: int, shards: int, broken: int):
	var curHeart := 0
	for node in $Hearts.get_children():
		var heart := node as AnimatedSprite
		if curHeart < hp:
			heart.play("full")
		elif curHeart == hp && shards > 0:
			heart.play("filling")
			heart.frame = shards - 1
			heart.stop()
		elif GlobalData.playerMaxHp - curHeart < broken:
			heart.play("broken")
		else:
			heart.play("empty")
		curHeart += 1
			
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		GlobalData.playerHp -= 1
		print("Oof!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
