extends Control

const kInitCharDelay := 0.3
const kBaseCharDelay := 0.15
const kCharDelayMod := 0.01

var root: DialogueArray = null
var curArray: DialogueArray = null
var curDialogue = null setget set_cur_dialogue
var curDispDialogue: DialogueArray.Dialogue = null

onready var label := $TextBox/RichTextLabel
var nextCharTimer := kInitCharDelay
var awaitingInput := false
var initialized := false

func set_cur_dialogue(val):
	curDialogue = val
	if val is DialogueArray.DialogueBranch:
		curDispDialogue = val.dialogue
	else:
		curDispDialogue = val
	label.text = curDispDialogue.text
	label.visible_characters = 0
	nextCharTimer = 0.0

func text_scroll_finished():
	awaitingInput = true

func init(path: String = "res://Dialogue/test.json"):
	var file := File.new()
	Utility.print_errors([
		file.open(path, File.READ),
	])
	var dict := parse_json(file.get_as_text()) as Dictionary
	root = DialogueArray.new(dict["tree"], null)
	file.close()
	initialized = true
	
func _ready():
	if !initialized:
		init()
	get_tree().paused = true
	curArray = root
	set_cur_dialogue(root.get_first().dialogue)
	
func _process(delta):
	nextCharTimer -= 5 * delta if Input.is_action_pressed("ui_accept") else delta
	while !awaitingInput && nextCharTimer < 0.0:
		nextCharTimer += kBaseCharDelay
		label.visible_characters += 1
		if label.visible_characters > label.text.length():
			text_scroll_finished()
			
	if awaitingInput && Input.is_action_just_pressed("ui_accept"):
		var next := curArray.next()
		if next == null: # Textbox is finished
			$AnimationPlayer.play_backwards("Open")
			yield($AnimationPlayer, "animation_finished")
			queue_free()
			get_tree().paused = false
		else:
			curArray = next.array
			set_cur_dialogue(next.dialogue)
			awaitingInput = false
