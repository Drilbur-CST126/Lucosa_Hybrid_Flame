extends CutsceneAction

func activate():
	.activate()
	
	if GlobalData.camera != null:
		GlobalData.camera.target = GlobalData.camera.get_path_to(self)
	
	finish()
	
func _exit_tree():
	if GlobalData.camera != null && cutscene.player != null:
		GlobalData.camera.target = GlobalData.camera.get_path_to(cutscene.player)
