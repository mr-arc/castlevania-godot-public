extends Node2D

onready var secretArea: = $SecretArea
onready var hiddenTreasure: = $HiddenTreasure
onready var simon: = Globals.getSimon()

func _process(delta):
	if not hiddenTreasure.isRevealed and simon.isDucking and secretArea.overlaps_body(simon):
		hiddenTreasure.reveal()


func _on_DeathArea_body_entered(body):
	if body is Simon:
		body.position.y += 8000
		body.instaKill()
	else:
		body.queue_free()
