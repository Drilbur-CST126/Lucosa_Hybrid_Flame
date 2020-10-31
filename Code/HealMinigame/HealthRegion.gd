tool
extends StaticBody2D

const kMaxShards := 3
const kMaxHeight := 20
const kMinHeight := 10

export(int, 1, 3) var shards := 1 setget set_shards
export var width := 10 setget set_width

var height := 10 setget set_height

func get_class() -> String:
	return "HealthRegion"

func set_shards(val: int):
	shards = val
	var lerpAmt := 1.0 * val / kMaxShards
	set_height(lerp(kMinHeight, kMaxHeight, lerpAmt))
	modulate = Utility.lerp_color(Color(0x000000FF), Color(0xFFFFFFFF), lerpAmt)

func set_width(val: int):
	width = val
	update_collision_shape()
	update_color_rect()
	
func set_height(val: int):
	height = val
	update_collision_shape()
	update_color_rect()
	
func update_collision_shape():
	if get_node_or_null("CollisionShape2D") != null:
		$CollisionShape2D.shape.extents = Vector2(width, height)
	
func update_color_rect():
	if get_node_or_null("ColorRect") != null:
		$ColorRect.margin_left = -width
		$ColorRect.margin_right = width
		$ColorRect.margin_top = -height
		$ColorRect.margin_bottom = height

func _ready():
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.extents = Vector2(width, height)
	update_color_rect()
