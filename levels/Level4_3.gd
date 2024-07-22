extends Node2D

onready var frank: = $Level4_3/Frank
onready var igor: = $Level4_3/Igor
onready var bossWall: = $Level4_3/Bosswall
onready var hud: = Globals.getHud()

func _ready():
	bossWall.collision_layer = 0


func _on_BossArea_bossReady():
	Stats.reachedBoss("Frankenstein", Globals.currentStage)
	frank.wakeUp()
	igor.wakeUp()


func _on_BossArea_body_entered(body):
	bossWall.collision_layer = 1


func _on_Frank_damaged(maxHealth, healthRemaining):
	var ratio = 16.0 / maxHealth
	hud.enemyHealth.health = round(healthRemaining * ratio)


func _on_Frank_dead():
	Globals.explodeNode(igor, igor.global_position, "", true)
	$EndLevelData.spawnCrystal()
