extends CutsceneAction

func activate():
	.activate()
	
	if GlobalData.camera != null:
		GlobalData.camera.target = GlobalData.camera.get_path_to(self)
	
	finish()
	
func _exit_tree():
	on_cutscene_finished()
		
func on_cutscene_finished():
	if GlobalData.camera != null && cutscene.player != null:
		GlobalData.camera.target = GlobalData.camera.get_path_to(cutscene.player)
