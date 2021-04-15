extends CutsceneAction

enum Direction {Left, Right, Toggle}

export(Direction) var direction

func activate():
	.activate()
	match direction:
		Direction.Left:
			cutscene.mockPlayer.facingRight = false
		Direction.Right:
			cutscene.mockPlayer.facingRight = true
		Direction.Toggle:
			cutscene.mockPlayer.facingRight = !cutscene.mockPlayer.facingRight
	finish()
