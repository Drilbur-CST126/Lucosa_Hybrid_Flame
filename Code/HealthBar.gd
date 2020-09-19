extends CanvasLayer

const Health = preload("res://Code/Health.tscn")
const TransitionEffect = preload("res://Code/Polish/TransitionEffect.tscn")

const bg := Color("#544b46")
const FIRST_HEART_OFFSET := 180
const NEXT_HEART_OFFSET := 90

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var curNumHearts := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalData.connect("max_hp_changed", self, "adjust_max_hp_display")
	GlobalData.connect("hp_changed", self, "adjust_hp_display")
	GlobalData.connect("trans_begin", self, "begin_transition")
	adjust_max_hp_display(GlobalData.playerMaxHp)
	
	if GlobalData.transDirection != null:
		end_transition()
	
func set_icon(form: String):
	$Visuals/RuiruiIcon.visible = form == "ruirui"
	$Visuals/LucosaIcon.visible = form == "lucosa"
	
func adjust_max_hp_display(maxHp: int):
	#$Background.margin_right = 3 + (12 * maxHp)
	if curNumHearts < maxHp:
		for i in range(maxHp - curNumHearts):
			var heart := Health.instance()
			heart.position.x = FIRST_HEART_OFFSET + (NEXT_HEART_OFFSET * (i + curNumHearts))
			$Hearts.add_child(heart)
	
	curNumHearts = maxHp
	adjust_hp_display(GlobalData.playerHp, GlobalData.hpShards)

func adjust_hp_display(hp: int, shards: int):
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
			
func begin_transition(direction, destination: String, inverse := false):
	get_tree().paused = true
	var effect := TransitionEffect.instance()
	effect.set_dimensions(ProjectSettings.get_setting("display/window/size/width") / scale.x, \
			ProjectSettings.get_setting("display/window/size/height") / scale.y)
	effect.set_direction(direction)
	effect.connect("finished", get_tree(), "change_scene", [destination])
	add_child(effect)
	
func end_transition():
	get_tree().paused = false
	var effect := TransitionEffect.instance()
	effect.inverse = true
	effect.set_dimensions(ProjectSettings.get_setting("display/window/size/width") / scale.x, \
			ProjectSettings.get_setting("display/window/size/height") / scale.y)
	effect.set_direction(GlobalData.transDirection)
	effect.connect("finished", effect, "queue_free")
	add_child(effect)
