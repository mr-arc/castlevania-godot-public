extends Node2D

onready var secretArea: = $SecretArea
onready var hiddenTreasure: = $HiddenTreasure

func _on_Exit_body_entered(simon):
	if simon is Simon:
#		simon.position.y = 0
		simon.startCutscene()
		if simon.position.x < $Exit.position.x:
			_walkToExit()
		else:
			simon.walkTo($Exit.position.x, funcref(self, "_walkToExit"))
		
func _walkToExit():
	secretArea.monitoring = false
	var simon = Globals.getSimon()
	Globals.playSound(Globals.PORTAL_ENTRY, simon.position)
	$WallOverlay.visible = true
	simon.walkTo($WalkDest.position.x, funcref(self, "_exitComplete"))
		
func _exitComplete():
	var simon = Globals.getSimon()
	print("level ended!")
	simon.endCutscene()
	simon.reset_physics_interpolation()
	Globals.call_deferred("loadLevel", "res://levels/Level1_1.tscn")

func _on_SecretArea_body_entered(body):
	hiddenTreasure.reveal()
