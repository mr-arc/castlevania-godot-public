extends Node

const CRYSTAL = preload("res://items/Crystal.tscn")

onready var timeCountStream: = $TimeCountStream
onready var heartCountStream: = $HeartCountStream
onready var timer: = $Timer

enum State {
	IDLE,
	HEALTH,
	TIME,
	HEARTS,
	CUTSCENE,
}

var state = State.HEALTH

func spawnCrystal(spawnPoint: Node, nextLevelNum: int, nextLevel: String):
	timer.wait_time = 2
	timer.start()
	yield(timer, "timeout")
	var crystal = CRYSTAL.instance()
	spawnPoint.add_child(crystal)
	yield(crystal,"pickedUp")
	
	# Advance to next level.
	doEndLevel(nextLevelNum, nextLevel)

func _physics_process(delta):
	if state == State.TIME:
		if Globals.getGame().timeRemaining <= 0:
			return
		Globals.getGame().timeRemaining -= 1
		Globals.getSimon().score += 20
	

func doEndLevel(nextLevelNum: int, nextLevelSceneName: String):
	var simon = Globals.getSimon()
	var game = Globals.getGame()
	Stats.levelcompleted(
		Globals.currentStage, simon.score, simon.hearts, simon.health, 
		simon.lives, round(game.gameTimer.time_left))
	
	state = State.HEALTH
	# Stop level timer
	game.stopTimer()
	if nextLevelNum == 7:
		MusicPlayer.playMusic("res://music/15 All Clear.mp3", false)
	else:
		MusicPlayer.playLevelComplete()
	
	# First give simon back all his health.
	# One bar at a time, no sound
	while simon.health < simon.MAX_HEALTH:
		simon.health += 1
		timer.wait_time = 0.25
		timer.start()
		yield(timer, "timeout")
		
	# if music is still playing, wait till its done
	if MusicPlayer.playing:
		yield(MusicPlayer, "finished")
	
	# Next  count off timer seconds, 20 pts per second left
	# We do the time deduction in physics_process, 1 per frame, but we play the 
	# sound here
	state = State.TIME
	while game.timeRemaining > 0:
		timeCountStream.play()
		timer.wait_time = 0.1
		timer.start()
		yield(timer, "timeout")

	state = State.HEARTS
	timer.wait_time = 1
	timer.start()
	yield(timer, "timeout")

	# Count of hearts, 100 pts per heart, down to zero
	while simon.hearts > 0:
		simon.hearts -= 1
		simon.score += 100
		heartCountStream.play()
		timer.wait_time = 0.2
		timer.start()
		yield(timer, "timeout")
		
	# Wait another second before loading the cutscene.
	timer.wait_time = 1.0
	timer.start()
	yield(timer, "timeout")
	
	if nextLevelNum == 7:
		yield(get_tree().create_tween().tween_property(game, "modulate", Color(0, 0, 0), 2.0), "finished")
		Globals.changeScene("res://levels/Ending.tscn")
		return
		
	# Play the map cutscene
	state = State.CUTSCENE
	var nextLevelScene = load("res://levels/NextLevelScene.tscn").instance()
	nextLevelScene.levelNum = nextLevelNum
	game.levelScene.queue_free()
	game.levelScene = null
	# temporarily move the "real" simon away from everything
	simon.position.y = 10000
	game.level.add_child(nextLevelScene)
	game.getCamera().position = Vector2.ZERO
	yield(nextLevelScene, "done")
	simon.visible = true
	simon.endCutscene()
	nextLevelScene.queue_free()
	
	# Give simon 5 hearts to start with.
	simon.hearts = 5
	
	game.loadLevel(nextLevelSceneName)
	
	
	
	
	
	
