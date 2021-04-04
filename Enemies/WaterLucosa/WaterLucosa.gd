extends KinematicBody2D

const Projectile := preload("res://Enemies/WaterLucosa/Projectile/Projectile.tscn")	

export var requireAmulet := true

func _ready():
	Utility.print_errors([
		$ProjectileTimer.connect("timeout", self, "fire_projectile"),
		$VisibilityNotifier.connect("screen_entered", self, "enable_on_screen"),
		$VisibilityNotifier.connect("screen_exited", self, "disable_on_screen"),
	])
	if requireAmulet && !GlobalData.hasExplosionImmunity:
		queue_free()
	
func fire_projectile():
	var proj := Projectile.instance()
	proj.target = GlobalData.player
	get_parent().add_child(proj)
	proj.global_position = global_position
	proj.focus_on_target()
	
	if $VisibilityNotifier.onScreen:
		$ProjectileTimer.start()
		
func enable_on_screen():
	if $ProjectileTimer.time_left == 0.0:
		$ProjectileTimer.start()
	
func disable_on_screen():
	pass
