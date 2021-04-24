extends Area2D

const kEnemyDamage := 4
const kPlayerDamage := 2
const kPlayerKnockback := 12.0

func _ready():
	Utility.print_connect_errors(get_path(), [
		$DisableHitboxTimer.connect("timeout", self, "disable_hitbox"),
		$AnimationPlayer.connect("animation_finished", self, "destruct"),
		connect("body_entered", self, "entity_entered"),
		connect("area_entered", self, "entity_entered"),
	])
	GlobalData.camera.shake(3.0, 0.2)
	$Sound.volume_db = linear2db(GlobalData.sfxVolume)
	$Sound.play()
	
func disable_hitbox():
	$CollisionShape2D.disabled = true

func destruct(_anim):
	queue_free()
	
func entity_entered(ent: Node2D):
	if ent.has_node("EnemyData"): # If the entity is an enemy
		var enemyData = ent.get_node("EnemyData")
		enemyData.take_damage(kEnemyDamage, self)
	elif ent.get_class() == GlobalData.kPlayerClassName: # If the entity is the player
		if !GlobalData.hasExplosionImmunity:
			GlobalData.playerHp -= kPlayerDamage
		elif GlobalData.lucosaForm:
			ent.canDoubleJump = GlobalData.hasUppercut
		else:
			ent.canDoubleJump = GlobalData.hasDoubleJump
		var explosionImpulse = sqrt(16.0 * kPlayerKnockback * ent.gravity)
		var velocity := Vector2(0.0, -explosionImpulse)
		ent.velocity = velocity
		ent.state = ent.ActionState.Falling
