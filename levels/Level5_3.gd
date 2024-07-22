extends Node2D

onready var game: = Globals.getGame()
onready var bossWall: = $Level5_3/BossWall
onready var animationPlayer: = $AnimationPlayer
onready var reaper: = $GrimReaper
onready var hud: = Globals.getHud()


func _ready():
	bossWall.collision_layer = 0


func _on_BossArea_bossReady():
	Stats.reachedBoss("Grim Reaper", Globals.currentStage)
	animationPlayer.play("SpawnReaper")
	yield(animationPlayer, "animation_finished")
	reaper.wakeUp()


func _on_BossArea_body_entered(body):
	bossWall.collision_layer = 1
	# Remove any other enemies on the level so they don't interfere with the boss fight
	for node in get_tree().get_nodes_in_group("AffectedByRosary"):
		node.queue_free()


func _on_GrimReaper_dead():
	$EndLevelData.spawnCrystal()


func _on_GrimReaper_damaged(maxHealth, healthRemaining):
	var ratio = 16.0 / maxHealth
	hud.enemyHealth.health = round(healthRemaining * ratio)
