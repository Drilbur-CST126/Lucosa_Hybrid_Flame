extends Node2D

const healthFire := Color("#ba482f")
const white := Color("#FFFFFF")

const MAX_FLASH_TIME := 0.1

const STATES := {
	"Full": -1,
	"Empty": -2
	#Filling is states 1-5
}


var animTime := 0.0
var flashing := false
var filling := false
var state: int = STATES["Full"]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func flash():
	animTime = MAX_FLASH_TIME
	$Flash.visible = true
	flashing = true

func set_full():
	#play("full")
	$Fill.show()
	$Fill.modulate = healthFire
	$Fill.region_rect.size.y = 99
	$Fill.region_rect.position.y = 0
	$Fill.offset.y = 0
	$Fire.show()
	if state != STATES["Full"]:
		flash()
	state = STATES["Full"]
	
func set_empty():
	$Fill.hide()
	$Fire.hide()
	if state != STATES["Empty"]:
		flash()
	state = STATES["Empty"]

func set_filling(amt: int):
	$Fill.show()
	$Fill.modulate = white
#	var ofs := amt * 20
#	$Fill.region_rect.size.y = ofs
#	$Fill.region_rect.position.y = 100 - ofs
#	$Fill.offset.y = (100 - ofs) / 2.0
	$Fire.hide()
	if state != amt:
		flash()
	state = amt
	flashing = false
	filling = true
	animTime = MAX_FLASH_TIME

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (flashing):
		$Flash.modulate.a = animTime / MAX_FLASH_TIME
		animTime -= delta
		flashing = animTime > 0.0
	elif($Flash.visible):
		$Flash.visible = false
		
	if (filling):
		var src := (state - 1) * 20
		var cur := state * 20
		var pos := lerp(cur, src, animTime / MAX_FLASH_TIME) as float
		var ofs = 100 - pos
		$Fill.region_rect.size.y = pos
		$Fill.region_rect.position.y = ofs
		$Fill.offset.y = ofs / 2.0
		
		animTime -= delta
		filling = animTime > 0.0
