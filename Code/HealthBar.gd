extends CanvasLayer

const Health = preload("res://Code/Health.tscn")

const bg := Color("#544b46")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var curNumHearts := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalData.connect("max_hp_changed", self, "adjust_max_hp_display")
	GlobalData.connect("hp_changed", self, "adjust_hp_display")
	adjust_max_hp_display(GlobalData.playerMaxHp)
	
func set_icon(form: String):
	$Visuals/RuiruiIcon.visible = form == "ruirui"
	$Visuals/LucosaIcon.visible = form == "lucosa"
	
func adjust_max_hp_display(maxHp: int):
	$Background.margin_right = 3 + (12 * maxHp)
	if curNumHearts < maxHp:
		for i in range(maxHp - curNumHearts):
			var heart := Health.instance()
			heart.offset.x = 7 + (12 * (i + curNumHearts))
			$Hearts.add_child(heart)
	
	curNumHearts = maxHp
	adjust_hp_display(GlobalData.playerHp, GlobalData.hpShards, 0)

func adjust_hp_display(hp: int, shards: int, broken: int):
	var curHeart := 0
	for node in $Hearts.get_children():
		var heart = node
		if curHeart < hp:
			heart.set_full()
		elif curHeart == hp && shards > 0:
			heart.set_filling(shards)
		else:
			heart.set_empty()
		curHeart += 1
			
func _process(_delta):
	pass
