extends Area2D

const GHOUL = preload("res://enemies/Ghoul.tscn")
const BAT = preload("res://enemies/Bat.tscn")
const FISHMAN = preload("res://enemies/Fishman.tscn")
const MEDUSA_HEAD = preload("res://enemies/MedusaHead.tscn")
const EAGLE = preload("res://enemies/Eagle.tscn")

const SPLASH = preload("res://Splash.tscn")

const SPAWN_X_OFFSET = 8
const SPAWN_Y_OFFSET = -3

const SPAWN_FISHMAN_MIN_OFFSET = 32
const SPAWN_FISHMAN_MAX_OFFSET = 128

onready var spawnTimer: = $SpawnTimer
onready var spawnShape: CollisionShape2D
onready var enemies: = $Enemies
onready var camera := Globals.getGame().getCamera()

export(String, "ghoul", "fishman", "bat", "medusahead", "eagle") var enemy = "ghoul"
export(int) var maxEnemies = 3
export(float) var minSpawnTime = 0.3
export(float) var maxSpawnTime = 3.5
export(float) var firstSpawnTime = -1 
			
func _on_SpawnArea_child_entered_tree(node):
	for child in get_children():
		if child is CollisionShape2D:
			spawnShape = child
	update_configuration_warning()
			
func _get_configuration_warning():
	if not spawnShape:
		return "A CollisionShape2D is required with a RectangleShape2D shape."
	if spawnShape.shape is RectangleShape2D:
		return ""
	return "The child CollisionShape2D must have a RectangleShape2D shape."
	
func _on_SpawnArea_body_entered(body):
	if body is Simon:
		if firstSpawnTime == 0:
			call_deferred("spawnIfAble", true)
		elif firstSpawnTime > 0:
			spawnTimer.wait_time = firstSpawnTime
			spawnTimer.start()
		else:
			_resetSpawnTimer()
		
func _on_SpawnArea_body_exited(body):
	if body is Simon:
		spawnTimer.stop()
		
func spawnIfAble(resetSpawnTimer: bool = false):
	if enemies.get_child_count() < maxEnemies:
		_spawn()
	if resetSpawnTimer:
		_resetSpawnTimer()

func _on_SpawnTimer_timeout():
	# Only spawn if less than limit of enemies.
	spawnIfAble(true)
	
func _getRandomSpawnTime() -> float:
	return rand_range(minSpawnTime, maxSpawnTime)
	
func _createEnemy() -> Node:
	match enemy:
		"ghoul":
			return GHOUL.instance()
		"bat":
			return BAT.instance()
		"fishman":
			var fishman = FISHMAN.instance()
			fishman.leap()
			return fishman
		"medusahead":
			return MEDUSA_HEAD.instance()
		"eagle":
			return EAGLE.instance()
	return null
	
func _spawn() -> void:
	var instance = _createEnemy()
	var location = _getSpawnLocation()
	if enemy == "fishman":
		var splash = SPLASH.instance()
		splash.find_node("AudioStreamPlayer2D").stream = Globals.SMALL_SPLASH
		instance.add_child(splash)
		splash.restart()
	enemies.add_child(instance)
	print("spawning an enemy in {0} at {1}".format([name, location]))
	instance.global_position = location
	if enemy == "medusahead":
		instance.resetStartPosition()
	if Globals.getSimon().global_position.x > location.x:
		instance.faceRight()
	else:
		instance.faceLeft()
	
func _resetSpawnTimer() -> void:
	spawnTimer.wait_time = _getRandomSpawnTime()
	spawnTimer.start()
	
func _getSpawnLocation() -> Vector2:
	var spawnArea = spawnShape.shape as RectangleShape2D
	var camXMin = camera.position.x - camera.get_viewport_rect().size.x / 2
	var camXMax = camera.position.x + camera.get_viewport_rect().size.x / 2 
	var globalAreaPosition = spawnShape.global_position
	var areaXLeft = globalAreaPosition.x - spawnArea.extents.x
	var areaXRight = globalAreaPosition.x + spawnArea.extents.x
	var areaYBottom = globalAreaPosition.y + spawnArea.extents.y
	var areaYTop = globalAreaPosition.y - spawnArea.extents.y
	
	if enemy == "ghoul":
		# First, figure out if we're spawning to the left or right.
		var spawnLeft = randi() % 2 == 0
		var spawnX = (camXMin - SPAWN_X_OFFSET) if spawnLeft else (camXMax + SPAWN_X_OFFSET)
		
		# spawn at the bottom
		var spawnY = globalAreaPosition.y + spawnArea.extents.y + SPAWN_Y_OFFSET
		
		# If side of the area is on-screen, then switch sides
		if spawnLeft and areaXLeft >= camXMin:
			spawnLeft = false
		elif not spawnLeft and areaXRight <= camXMax:
			spawnLeft = true
		return Vector2(spawnX, spawnY)
	
	elif enemy == "eagle":
		var spawnLeft = randi() % 2 == 0
		var spawnX = (camXMin - SPAWN_X_OFFSET) if spawnLeft else (camXMax + SPAWN_X_OFFSET)
		var maxY = areaYBottom - 60
		var minY = areaYTop + 20
		var spawnY = floor(rand_range(minY, maxY))
		
		return Vector2(spawnX, spawnY)
		
	elif enemy == "bat" or enemy == "medusahead":
		# Bats always spawn on the side of the screen Simon is facing.
		var simon = Globals.getSimon()
		var spawnX = (camXMin - SPAWN_X_OFFSET) if simon.isFacingLeft() else (camXMax + SPAWN_X_OFFSET)
		return Vector2(spawnX, simon.global_position.y - 16)
		
	elif enemy == "fishman":
		var simon = Globals.getSimon()
		var multiplier = 1 if randi() % 2 == 0 else -1
		var offset = randi() % (
				SPAWN_FISHMAN_MAX_OFFSET - SPAWN_FISHMAN_MIN_OFFSET) + SPAWN_FISHMAN_MIN_OFFSET
		var spawnX = simon.global_position.x + multiplier * offset
		# flip to other side if spawning outside of the area
		if spawnX > areaXRight or spawnX < areaXLeft:
			spawnX = simon.global_position.x + -multiplier * offset
		return Vector2(spawnX, areaYBottom)
		
	return Vector2.ZERO
	
func _getSpawnLocationX():
	var simon = Globals.getSimon()
	
