extends Npc

enum Type {Earth, Water}

const EarthLucosa := preload("res://Enemies/EarthLucosa/EarthLucosa.tscn")
const WaterLucosa := preload("res://Enemies/WaterLucosa/WaterLucosa.tscn")

export(Type) var type
export var becomeEnemy := true

func _ready():
	if GlobalData.hasExplosionImmunity:
		if becomeEnemy:
			var en
			match type:
				Type.Earth:
					en = EarthLucosa.instance()
				Type.Water:
					en = WaterLucosa.instance()
			get_parent().call_deferred("add_child_below_node", self, en)
			en.global_position = self.global_position
		queue_free()
