extends CutsceneAction

enum Direction {Left, Right, Toggle}

export(Direction) var direction

func activate():
	.activate()
	match direction:
		Direction.Left:
			cutscene.mockPlayer.set_facing_right(false)
		Direction.Right:
			cutscene.mockPlayer.set_facing_right(true)
		Direction.Toggle:
			cutscene.mockPlayer.set_facing_right(!cutscene.mockPlayer.facingRight)
	cutscene.mockPlayer.play_anim("Idle")
	finish()
