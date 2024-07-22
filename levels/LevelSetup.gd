extends Node
class_name LevelSetup

export(bool) var faceRight: bool = true
export(String, FILE, "*.mp3") var music: String = "res://music/02 Vampire Killer.mp3"
export(int) var stage: int = 1
export(Vector2) var cameraPosition: Vector2
export(bool) var startFollowingSimon: bool = true
export(int) var timeLimit = 300

func startLevel():
	var simon = Globals.getSimon()
	Globals.currentStage = stage
	if faceRight:
		Globals.getSimon().faceRight()
	else:
		Globals.getSimon().faceLeft()
		
	MusicPlayer.playMusic(music)
	
	Globals.getHud().setStage(stage)
	var game = Globals.getGame()
	game.getCamera().position = getResetCameraPosition()
	game.cameraY = game.getCamera().position.y
	
	game.followSimon = startFollowingSimon
	
	# Level 4 (stage 10) we need top drop simon from the sky
	if not Globals.startedStage10 and stage == 10:
		Globals.startedStage10 = true
		var dropPosition = game.levelScene.find_node("SimonDrop", true, false)
		if not dropPosition.is_inside_tree():
			yield(dropPosition, "tree_entered")
		Globals.getSimon().global_position = dropPosition.global_position
		Globals.getSimon().jumpY = dropPosition.global_position.y
	
func getResetCameraPosition():
	return Vector2(cameraPosition.x + 8 * 16, cameraPosition.y + 4 * 16)
