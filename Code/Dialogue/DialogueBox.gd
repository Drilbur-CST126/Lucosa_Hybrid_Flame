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
var awaitingOption := false
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
	
	if curDispDialogue.speaker != null:
		$TextBox/Name.visible = true
		$TextBox/Name/RichTextLabel.text = curDispDialogue.speaker
	else:
		$TextBox/Name.visible = false

func text_scroll_finished():
	if curDialogue is DialogueArray.Dialogue:
		awaitingInput = true
	if curDialogue is DialogueArray.DialogueBranch:
		var lastBtn: Button = null
		var index := 0
		for option in curDialogue.options:
			var textBox := ColorRect.new()
			textBox.color = $Background.color
			textBox.show_behind_parent = true
			textBox.anchor_bottom = 1
			textBox.anchor_right = 1
			
			var btn := Button.new()
			btn.text = option
			btn.flat = true
			Utility.set_font(btn, "res://Graphics/Fonts/Lato12.tres")
			
			Utility.print_errors([
				btn.connect("button_down", self, "option_selected", [index])
			])
			index += 1
			
			btn.add_child(textBox)
			$Options.add_child(btn)
			
			if lastBtn != null:
				btn.focus_next = lastBtn.get_path()
				btn.focus_neighbour_top = lastBtn.get_path()
				btn.focus_neighbour_left = lastBtn.get_path()
				lastBtn.focus_previous = btn.get_path()
				lastBtn.focus_neighbour_right = btn.get_path()
				lastBtn.focus_neighbour_bottom = btn.get_path()
			else:
				btn.grab_focus()
			lastBtn = btn
			
		awaitingOption = true
		
func option_selected(index: int):
	var newPath := (curDialogue.get_child(index) as DialogueArray)
	var first := newPath.get_first()
	curArray = first.array
	set_cur_dialogue(first.dialogue)
	
	for child in $Options.get_children():
		child.queue_free()
	awaitingOption = false

func init(path: String = "res://Dialogue/test.json"):
	var file := File.new()
	Utility.print_errors([
		file.open(path, File.READ),
	])
	var dict := parse_json(file.get_as_text()) as Dictionary
	root = DialogueArray.new(dict["tree"], null)
	file.close()
	initialized = true
	add_child(root)
	
static func input_down() -> bool:
	return Input.is_action_pressed("ui_accept") || Input.is_action_pressed("ui_cancel")
	
static func input_just_down() -> bool:
	return Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("ui_cancel")
	
func _ready():
	if !initialized:
		init()
	get_tree().paused = true
	curArray = root
	set_cur_dialogue(root.get_first().dialogue)
	
func _process(delta):
	nextCharTimer -= 8 * delta if input_down() else delta
	while !(awaitingInput || awaitingOption) && nextCharTimer < 0.0:
		nextCharTimer += kBaseCharDelay
		$CharBeep.play()
		label.visible_characters += 1
		if label.visible_characters > label.text.length():
			text_scroll_finished()
			
	if awaitingInput && input_just_down():
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
