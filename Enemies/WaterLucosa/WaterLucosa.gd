extends KinematicBody2D

const Projectile := preload("res://Enemies/WaterLucosa/Projectile/Projectile.tscn")	

export var requireAmulet := true

var facingRight := false

func _ready():
	Utility.print_errors([
		$ProjectileTimer.connect("timeout", self, "start_fire_projectile"),
		$VisibilityNotifier.connect("screen_entered", self, "enable_on_screen"),
		$VisibilityNotifier.connect("screen_exited", self, "disable_on_screen"),
		$AnimationPlayer.connect("animation_finished", self, "on_anim_finished"),
	])
	if requireAmulet && !GlobalData.hasExplosionImmunity:
		queue_free()
		
func _process(_delta):
	if GlobalData.player != null:
		var playerPos := GlobalData.player.global_position.x
		var newFacingRight := playerPos > global_position.x
		if newFacingRight != facingRight:
			facingRight = newFacingRight
			var dir = Utility.get_dir(facingRight)
			$Graphics/Sprite.scale.x = dir * -0.167
		
func on_anim_finished(anim):
	match anim:
		"FireBubble":
			fire_projectile()
		"PostBubbleLinger":
			if $VisibilityNotifier.onScreen:
				start_projectile_timer()
			else:
				$AnimationPlayer.play("Stand")
	
func fire_projectile():
	var proj := Projectile.instance()
	proj.target = GlobalData.player
	get_parent().add_child(proj)
	proj.global_position = global_position
	proj.global_position.x += 2 * Utility.get_dir(facingRight)
	proj.focus_on_target()
	$AnimationPlayer.play("PostBubbleLinger")
	
func start_projectile_timer():
	$ProjectileTimer.start()
	$AnimationPlayer.play("CreateBubble")
	
func start_fire_projectile():
	$AnimationPlayer.play("FireBubble")
		
func enable_on_screen():
	if $ProjectileTimer.time_left == 0.0:
		start_projectile_timer()
	
func disable_on_screen():
	pass
