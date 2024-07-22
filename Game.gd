extends Node2D
class_name Game

const SIMON = preload("res://Simon.tscn")
const MAX_TIMER = 300
const START_CAMERA_Y = 64

onready var camera: = find_node("Camera2D") as Camera2D
onready var simon: = find_node("Simon") as Simon
onready var level: = find_node("Level") as Node2D
onready var gameTimer: = find_node("GameTimer") as Timer
onready var timerBeep: = $TimerBeep
onready var beepTimer: = $TimerBeep/Timer
onready var stopwatchTimer: = $StopwatchTimer
onready var stopwatchSound: = $StopwatchTimer/StopwatchSound

export(PackedScene) var startLevel = preload("res://levels/IntroScene.tscn")
export(int) var cameraY = START_CAMERA_Y
var cameraX = 0

var areaRect: Rect2
var levelScene
var currentLevelResource: PackedScene
var tileMap: TileMap
var followSimon: bool = true
var timeRemaining: int

func getCamera() -> Camera2D:
	return camera

# Called when the node enters the scene tree for the first time.
#func _ready():
#	loadPreloadedLevel(startLevel)

func start():
	loadPreloadedLevel(startLevel)

func _process(delta):
	if followSimon:
		moveCameraToSimon()
		
	if (not gameTimer.paused and not gameTimer.is_stopped() and gameTimer.time_left > 0 
			and gameTimer.time_left < 20 and beepTimer.is_stopped()):
		timerBeep.play()
		beepTimer.start()
		
func loadLevel(levelResourceName: String):
	var levelResource = load(levelResourceName) as PackedScene
	loadPreloadedLevel(levelResource)
	
func makeCurrentLevel(resource: PackedScene, level: Node2D, repositionSimon: bool = false)->void:
	currentLevelResource = resource
	levelScene = level
	var levelSetup: LevelSetup = levelScene.get_node("LevelSetup")
	Stats.levelStart(levelSetup.stage)
	
	if repositionSimon:
		yield(get_tree(), "physics_frame")
		moveSimonToSpawnPosition(level)
		yield(get_tree(), "physics_frame")
		# Now move him back because he might have fallen...
		moveSimonToSpawnPosition(level)
	self.level.add_child(level)
	tileMap = levelScene.find_node("Tile Layer 1", true, false) as TileMap
	var tileMapParent = tileMap.get_parent()
	var rect = tileMap.get_used_rect()
	var size = tileMap.cell_size
	areaRect = Rect2(
		level.position.x + rect.position.x * size.x, 
		level.position.y + rect.position.y * size.y, 
		rect.size.x * size.x, 
		rect.size.y * size.y)
		
func getSimonCollisions():
	return simon.collision_layer != 0
	
func setSimonCollisions(value: bool):
	if value:
		simon.collision_layer = 2
		simon.collisionShape.set_deferred("disabled", false)
	else:
		simon.collision_layer = 0
		simon.collisionShape.set_deferred("disabled", true)

func _monitoringAreasPredicate(node: Node) -> bool:
	return node is Area2D and node.monitoring
		
	
func loadPreloadedLevel(levelResource, location = Vector2.ZERO):
	if levelScene:
		Stats.levelEnd(levelScene.get_node("LevelSetup").stage)
		levelScene.queue_free()

	var instance = levelResource.instance() as Node2D
	makeCurrentLevel(levelResource, instance, true)
	if not instance.is_inside_tree():
		yield(instance, "tree_entered")
	var levelSetup: LevelSetup = instance.get_node("LevelSetup")
	Globals.getHud().resetEnemyHealth()
	
	levelSetup.startLevel()
	resetGameTimer(levelSetup.timeLimit)
	
func moveSimonToSpawnPosition(levelInstance: Node):
	var collisionsBefore = getSimonCollisions()
#	setSimonCollisions(false)
	var simonSpawn = levelInstance.find_node("SimonSpawn")
	var spawnLocation: Vector2
	if levelInstance.is_inside_tree():
		spawnLocation = simonSpawn.global_position
	else:
		spawnLocation = level.to_global(simonSpawn.position)
	simon.position = spawnLocation
	simon.reset_physics_interpolation()
	simon.jumpY = simon.global_position.y
	simon.velocity = Vector2.ZERO
	simon.setIdle()
#	setSimonCollisions(collisionsBefore)


func resetGameTimer(timeLimit: int) -> void:	
	gameTimer.wait_time = timeLimit
	gameTimer.paused = false
	gameTimer.start()
	
# Returns the stair type at the player's current position.
func getStairType(globalLocation: Vector2) -> int:
	if tileMap:
		return StairFuncs.getStairType(tileMap, globalLocation)
	return StairType.NO_STAIRS
	
func getStairCase(globalLocation: Vector2) -> StairData:
	return StairFuncs.getStairCase(tileMap, globalLocation)
		
func _on_Simon_respawn():
	simon.position.y += 5000
	
	var scenePosition = levelScene.position
	levelScene.queue_free()
	
	loadPreloadedLevel(currentLevelResource, scenePosition)

	simon.resetState()
	followSimon = levelScene.get_node("LevelSetup").startFollowingSimon
	Globals.getHud().resetEnemyHealth()

	
# Returns time left on the game timer, OR the value of timeRemaining
# if the game timer is paused (stopped by end of level code)
func getRemainingTime() -> int:
	if gameTimer.paused:
		return timeRemaining
	else:
		return int(round(gameTimer.time_left))

func stopTimer() -> void:
	timeRemaining = getRemainingTime()
	gameTimer.paused = true
	
func moveCameraToYPosition():
	camera.position.y = cameraY
	
func moveCameraToSimon():		
	camera.position.x = simon.position.x
	camera.position.y = cameraY
	var camXMin = camera.position.x - camera.get_viewport_rect().size.x / 2
	var camXMax = camera.position.x + camera.get_viewport_rect().size.x / 2
	if areaRect.position.x > camXMin:
		camera.position.x += areaRect.position.x - camXMin
	elif areaRect.end.x < camXMax:
		camera.position.x -= camXMax - areaRect.end.x
	# We round to keep camera moves pixel-perfect.
	camera.position.x = round(camera.position.x)
	
# Initiates the stopwatch if able. Returns true if so.
func tryDoStopwatch() -> bool:
	if not stopwatchTimer.is_stopped():
		return false
	
	AudioServer.set_bus_volume_db(1, -12)
	stopwatchTimer.start()
	stopwatchSound.play()
	for node in get_tree().get_nodes_in_group("AffectedByClock"):
		_setNodePaused(node, true)
	return true

func _on_GameTimer_timeout():
	beepTimer.stop()
	simon.instaKill("Time Expired")

func _on_Timer_timeout():
	timerBeep.play()

func _on_StopwatchTimer_timeout():
	for node in get_tree().get_nodes_in_group("AffectedByClock"):
		_setNodePaused(node, false)
		
	AudioServer.set_bus_volume_db(1, 0)
	
func isStopwatchActive() -> bool:
	return not stopwatchTimer.is_stopped()
	
func _setNodePaused(node: Node, paused: bool) -> void:
	node.set_process(not paused)
	node.set_physics_process(not paused)
	if node is Timer:
		node.paused = paused
	if node is AnimationPlayer:
		if paused:
			node.stop(false)
		else:
			node.play()
	if node is AnimatedSprite:
		node.playing = not paused
	for child in node.get_children():
		_setNodePaused(child, paused)
