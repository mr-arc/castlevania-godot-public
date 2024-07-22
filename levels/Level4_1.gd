extends Node2D

const SPLASH: = preload("res://Splash.tscn")

func _ready():
	pass


func _on_DeathArea_body_entered(body):
	_makeSplash(body.global_position)
	# move him offscreen
	body.position.y += 1000
	
	if body is Simon:
		body.instaKill()
	else:
		body.queue_free()
	
func _makeSplash(location: Vector2):
	var splash = SPLASH.instance()
	add_child(splash)
	splash.global_position = location
	splash.restart()

func _on_GoToNextLevel_body_entered(simon: Simon):
	simon.startCutscene("UpSteps")
	simon.collision_layer = 0
	var nextLevelResource = load("res://levels/Level4_2.tscn")
	var nextLevel = nextLevelResource.instance()
	var simonSteps = nextLevel.get_node("SimonSteps")
	simon.position = simonSteps.position
	
	var simonSpawn = nextLevel.get_node("SimonSpawn")
	
	var levelSetup = nextLevel.get_node("LevelSetup") as LevelSetup
	
	var game = Globals.getGame()
	var camera = game.getCamera()
	
	yield(get_tree(), "idle_frame")
	game.makeCurrentLevel(nextLevelResource, nextLevel)
	MusicPlayer.playMusic(levelSetup.music)
	
	var tween = get_tree().create_tween() as SceneTreeTween
	tween.tween_property(simon, "position", simonSpawn.position, 2.0)
	yield(tween, "finished")
	queue_free()
	
	simon.collision_layer = 2
	simon.endCutscene()
	
	
