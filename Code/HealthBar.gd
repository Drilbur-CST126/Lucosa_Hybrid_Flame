extends CanvasLayer
class_name Hud

const Health = preload("res://Code/Health.tscn")
const TransitionEffect = preload("res://Code/Polish/TransitionEffect.tscn")
const DialogueBox = preload("res://Code/Dialogue/DialogueBox.tscn")

const kBarWidth := 548
const kIconHeight := 124.525
onready var kBarPos := $Visuals/BarInfill.position.x as float # Treated as const, as good as const
onready var kIconPos := $Visuals/IconInfill.position.y as float # Same as above

const bg := Color("#544b46")
const FIRST_HEART_OFFSET := 180
const NEXT_HEART_OFFSET := 90

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var curNumHearts := 0
var firstRun := true

var adjustHealthMutex := Mutex.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	Utility.print_connect_errors(get_path(), [
		GlobalData.connect("max_hp_changed", self, "adjust_max_hp_display"),
		GlobalData.connect("hp_changed", self, "adjust_hp_display"),
		GlobalData.connect("trans_begin", self, "begin_transition"),
		GlobalData.connect("mana_changed", self, "adjust_icon_display"),
		GlobalData.connect("player_dead", self, "begin_death_transition"),
	])
	GlobalData.hud = self
	adjust_max_hp_display(GlobalData.playerMaxHp)
	adjust_bar_display(GlobalData.playerMana)
	firstRun = false
	
	if GlobalData.transDirection != null:
		end_transition()
		
	yield(Utility.create_timer(self, 1.0), "timeout")
	#add_child(DialogueBox.instance())
	
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
	adjustHealthMutex.lock()
	var curHeart := 0
	for node in $Hearts.get_children():
		var heart = node
		if curHeart < hp:
			heart.set_full()
			if firstRun:
				heart.animTime = 0.0
		elif shards > 0:
			if shards > 5:
				heart.set_filling(5)
				shards -= 5
			else:
				heart.set_filling(shards)
				shards = 0
			if firstRun:
				heart.animTime = 0.0
		else:
			heart.set_empty()
			if firstRun:
				heart.animTime = 0.0
		curHeart += 1
	adjustHealthMutex.unlock()

func adjust_bar_display(mana: float):
	#print("MANA CHANGE")
	var width := kBarWidth * mana / (GlobalData.kMaxMana as float)
	$Visuals/BarInfill.region_rect.size.x = width
	$Visuals/BarInfill.position.x = kBarPos - kBarWidth / 2.0 + (width / 2.0)
	
func adjust_icon_display(infill: float):
	var height := kIconHeight * infill / (GlobalData.kMaxMana as float)
	$Visuals/IconInfill.region_rect.position.y = kIconHeight - height
	$Visuals/IconInfill.region_rect.size.y = height
	$Visuals/IconInfill.position.y = kIconPos + kIconHeight / 2.0 - (height / 2.0)
	
func show_dialogue_box(path: String):
	var dialogueBox := DialogueBox.instance()
	dialogueBox.init(path)
	GlobalData.hud.add_child(dialogueBox)
			
func begin_death_transition():
	var effect := TransitionEffect.instance()
	var height: float = ProjectSettings.get_setting("display/window/size/height") / scale.y
	effect.set_dimensions(ProjectSettings.get_setting("display/window/size/width") / scale.x, \
			height)
	#effect.duration *= 0.5
	effect.set_direction(GlobalData.Direction.Dtu)
	#GlobalData.transDirection = GlobalData.Direction.Fade
	effect.position.y = height + 16.0
	effect.delay = 1.0
	
	Utility.print_connect_errors(get_path(), [
		effect.connect("finished", GlobalData, "reload_game")
	])
	add_child(effect)
			
func begin_transition(direction, destination: String, inverse := false):
	get_tree().paused = true
	var effect := TransitionEffect.instance()
	effect.set_dimensions(ProjectSettings.get_setting("display/window/size/width") / scale.x, \
			ProjectSettings.get_setting("display/window/size/height") / scale.y)
	effect.set_direction(direction)
	effect.inverse = inverse
	Utility.print_connect_errors(get_path(), [
		effect.connect("finished", get_tree(), "change_scene", [destination])
	])
	add_child(effect)
	
func end_transition():
	get_tree().paused = false
	var effect := TransitionEffect.instance()
	effect.inverse = true
	effect.set_dimensions(ProjectSettings.get_setting("display/window/size/width") / scale.x, \
			ProjectSettings.get_setting("display/window/size/height") / scale.y)
	effect.set_direction(GlobalData.transDirection)
	Utility.print_connect_errors(get_path(), [
		effect.connect("finished", effect, "queue_free")
	])
	add_child(effect)
