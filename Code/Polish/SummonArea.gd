extends Control

export(String, FILE, "*.tscn,*.scn") var entity setget set_entity
export var numEntities := 25

var loadedEntity

func set_entity(val: String):
	entity = val
	loadedEntity = load(entity)
	
func reload_self():
	#if Engine.editor_hint:
		Utility.remove_children(self)
		if entity != null && entity != "":
			var area := rect_size.x * rect_size.y / 64.0
			for i in range(0, numEntities):
				var x = GlobalData.random.randf()
				var y = GlobalData.random.randf()
				var ent = loadedEntity.instance()
				ent.position = Vector2(lerp(0, margin_right - margin_left, x), \
						lerp(0, margin_bottom - margin_top, y))
				add_child(ent)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	reload_self()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
