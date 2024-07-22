extends Node2D

onready var simon: = Globals.getSimon()
onready var hiddenTreasure: = $Level3_1/HiddenTreasure
onready var secretTrigger: = $Level3_1/SecretTrigger
onready var ghostSpawner: = $GhostSpawner

var secretTriggered = false

func _on_DeathArea_body_entered(body):
	if body is Simon:
		body.position.y -= 10000
		body.instaKill()
		
func _process(delta):
	if not secretTriggered and secretTrigger.overlaps_body(simon) and simon.isDucking:
		secretTriggered = true
		hiddenTreasure.reveal()


func _on_GoUp1_teleported():
	ghostSpawner.removeAllGhosts()
