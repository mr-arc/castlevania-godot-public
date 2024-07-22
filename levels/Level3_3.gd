extends Node2D

onready var mummy1: = $Mummies/Mummy
onready var mummy2: = $Mummies/Mummy2
onready var hud: = Globals.getHud()
onready var maxHealth = mummy1.maxHealth + mummy2.maxHealth 
onready var currentHealth = maxHealth

var deadMummies = 0


func _on_DeathArea_body_entered(body):
	if body is Simon:
		body.position.y += 8000
		body.instaKill()
	else:
		body.queue_free()


func _on_BossArea_bossReady():
	Stats.reachedBoss("Mummy Men", Globals.currentStage)
	mummy1.wakeUp()
	mummy2.wakeUp()


func _on_Mummy_killed():
	deadMummies += 1
	if deadMummies >= 2:
		$EndLevelData.spawnCrystal()


func _on_Mummy_damaged(damage):
	currentHealth -= damage
	var ratio = 16.0 / maxHealth
	hud.enemyHealth.health = round(currentHealth * ratio)
