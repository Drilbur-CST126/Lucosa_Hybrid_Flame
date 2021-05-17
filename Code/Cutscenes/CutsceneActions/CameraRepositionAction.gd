extends CutsceneAction

export var snap := false

func activate():
	.activate()
	
	if GlobalData.camera != null:
		GlobalData.camera.target = GlobalData.camera.get_path_to(self)
		if snap:
			GlobalData.camera.global_position = global_position
	
	finish()
	
func _exit_tree():
	on_cutscene_finished()
		
func on_cutscene_finished():
	if GlobalData.camera != null && cutscene.player != null:
		GlobalData.camera.target = GlobalData.camera.get_path_to(cutscene.player)
