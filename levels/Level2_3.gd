extends Node2D

const MEDUSA_BOSS = preload("res://bosses/MedusaBoss.tscn")

onready var game = Globals.getGame()
onready var bossWall: = $BossWall
onready var medusaStatue: = $MedusaStatue
onready var hud: = Globals.getHud()
onready var setup: = $LevelSetup

func _on_BossArea_body_entered(body):
	if body is Simon:
		Stats.reachedBoss("Medusa", Globals.currentStage)
		bossWall.collision_layer = 1

func _on_BossArea_bossReady():
	var boss = MEDUSA_BOSS.instance()
	boss.top = $MedusaTop.get_path()
	boss.bottom = $MedusaBottom.get_path()
	boss.position = medusaStatue.position
	boss.connect("killed", self, "_on_Medusa_killed", [], CONNECT_ONESHOT)
	boss.connect("damaged", self, "_on_Medusa_damaged",  [boss.getHealth()])
	remove_child(medusaStatue)
	add_child(boss)
	boss.owner = self
	
func _on_GoUp1_teleported():
	$UpperGhostSpawner.removeAllGhosts()
	$LowerGhostSpawner.removeAllGhosts()
	
func _on_Medusa_killed():
	$EndLevelData.spawnCrystal()
	
func _on_Medusa_damaged(healthRemaining, maxHealth):
	var ratio = 16.0 / maxHealth
	hud.enemyHealth.health = round(healthRemaining * ratio)
