extends Node2D

onready var secretArea: = $Level6_2/SecretArea
onready var hiddenTreasure: = $Level6_2/HiddenTreasure
onready var simon: = Globals.getSimon()

func _on_ExitArea_body_entered(body):
	Globals.loadLevel("res://levels/Level6_3.tscn")
	
func _physics_process(delta):
	if not hiddenTreasure.isRevealed and simon.isDucking and simon in secretArea.get_overlapping_bodies():
		hiddenTreasure.reveal()
	
func _on_DeathArea_body_entered(body):
	if body is Simon:
		body.position.y += 10000
		body.instaKill()
	else:
		body.queue_free()
