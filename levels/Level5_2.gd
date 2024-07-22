extends Node2D

var secretSpawned = false
var secret2Spawned = false
var secret3Spawned = false

onready var hiddenTreasure: = $Level5_2/HiddenTreasure
onready var secretSpawnTimer: = $Level5_2/SecretSpawner/SecretSpawnTimer

onready var hiddenTreasure2: = $Level5_2/HiddenTreasure2
onready var secretSpawnTimer2: = $Level5_2/SecretSpawner2/SecretSpawnTimer2

onready var hiddenTreasure3: = $Level5_2/HiddenTreasure3
onready var secretSpawner3: = $Level5_2/SecretSpawner3

onready var simon: = Globals.getSimon()
onready var game: = Globals.getGame()


func _process(delta):
	if not secret3Spawned and simon.isDucking and simon in secretSpawner3.get_overlapping_bodies():
		secret3Spawned = true
		hiddenTreasure3.reveal()

func _on_SecretSpawner_body_entered(body):
	secretSpawnTimer.start()

func _on_SecretSpawner_body_exited(body):
	secretSpawnTimer.stop()

func _on_SecretSpawnTimer_timeout():
	hiddenTreasure.reveal()
	secretSpawned = true

func _on_SecretSpawner2_body_entered(body):
	secretSpawnTimer2.start()

func _on_SecretSpawner2_body_exited(body):
	secretSpawnTimer2.stop()

func _on_SecretSpawnTimer2_timeout():
	hiddenTreasure2.reveal()
	secret2Spawned = true
	
func _on_GoUp1_teleported():
	game.moveCameraToYPosition()
	game.followSimon = true

func _on_GoDown1_teleported():
	game.moveCameraToYPosition()

func _on_FollowArea_body_entered(body):
	game.followSimon = false


func _on_FollowArea_body_exited(body):
	game.followSimon = true
