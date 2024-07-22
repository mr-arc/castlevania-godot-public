extends Node2D

const CRYSTAL = preload("res://items/Crystal.tscn")

onready var bossWall: = $BossWall
onready var boss: = $PhantomBat
onready var hud: Hud = Globals.getHud()
onready var timer: = $Timer

func _on_BossArea_body_entered(body):
	if body is Simon:
		Stats.reachedBoss("Phantom Bat", Globals.currentStage)
		bossWall.collision_layer = 1

func _on_BossArea_bossReady():
	boss.wakeUp()

func _on_PhantomBat_dead():
	$EndLevelData.spawnCrystal()
	
func _on_PhantomBat_damaged(maxHealth, healthRemaining):
	var ratio = 16.0 / maxHealth
	hud.enemyHealth.health = round(healthRemaining * ratio)
