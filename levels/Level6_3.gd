extends Node2D

const DRACULA = preload("res://bosses/Dracula.tscn")
const COOKIE_MONSTER = preload("res://bosses/CookieMonster.tscn")
const SLAM_SOUND = preload("res://sounds/29 - Door Slam.wav")

onready var simon: = Globals.getSimon()
onready var game: = Globals.getGame()
onready var hud: = Globals.getHud()
onready var timer: = $Timer
onready var shakeTimer: = $ShakeTimer
onready var camera: = Globals.getGame().getCamera()
onready var activateDracula: = $Level6_3/ActivateDracula

func _on_DeathArea_body_entered(body):
	if body is Simon:
		body.position.y += 10000
		body.instaKill()


func _on_ActivateDracula_body_entered(body):
	Stats.reachedBoss("Dracula", Globals.currentStage)
	$Level6_3/BossWall.collision_layer = 1
	game.followSimon = false
	timer.wait_time = 1.25
	timer.start()
	yield(timer, "timeout")
	var dracula = DRACULA.instance()
	dracula.minDraculaX = $Level6_3/MinDracula.global_position.x
	dracula.maxDraculaX = $Level6_3/MaxDracula.global_position.x
	$Level6_3/DraculaSpawn.add_child(dracula)
	
	dracula.connect("dead", self, "_on_dracula_dead", [dracula])
	dracula.connect("damaged", self, "_on_dracula_damaged")
	dracula.connect("fatalDamage", self, "_on_dracula_fatalDamage")
	
func _on_dracula_fatalDamage():
	timer.wait_time = 1.3
	timer.start()
	yield(timer, "timeout")
	MusicPlayer.playMusic("res://music/14 Black Night.mp3")
	
func _on_dracula_dead(dracula):
	Stats.reachedBoss("CookieMonster", Globals.currentStage)
	var monster = COOKIE_MONSTER.instance()
	var location = dracula.global_position
	dracula.queue_free()
	add_child(monster)
	monster.connect("slam", self, "_on_monster_slam", [monster])
	monster.connect("damaged", self, "_on_dracula_damaged")
	monster.connect("dead", self, "_on_monster_dead", [monster])
	hud.enemyHealth.health = 16.0
	monster.global_position = location
	
func _on_dracula_damaged(maxHealth, healthRemaining):
	var ratio = 16.0 / maxHealth
	hud.enemyHealth.health = round(healthRemaining * ratio)

func _on_monster_slam(monster):
	Globals.playSound(SLAM_SOUND, monster.global_position)
	cameraShake()
	
func _on_monster_dead(monster):
	$EndLevelData.spawnCrystal()
	
func cameraShake():
	var cameraPos = camera.position
	camera.rotating = true
	for i in range(10):
		var xOffset = rand_range(-2, 2)
		var yOffset = rand_range(-2, 2)
		var rotOffset = rand_range(-1, 1)
		camera.position = cameraPos + Vector2(xOffset, yOffset)
		camera.rotation_degrees = rotOffset
		shakeTimer.start()
		yield(shakeTimer, "timeout")
		
	camera.rotation = 0
	camera.rotating = false
	camera.position = cameraPos
	
	
