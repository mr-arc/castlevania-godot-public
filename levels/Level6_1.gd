extends Node2D

var simonExiting = false
var exitStarted = false
onready var simon: = Globals.getSimon()
onready var exitPosition: = $Level6_1/ExitPosition

func _physics_process(delta):
	if simonExiting and not exitStarted and simon.is_on_floor():
		exitStarted = true
		doExit()
		
func doExit():
	Globals.playSound(Globals.PORTAL_ENTRY, simon.global_position)
	simon.startCutscene("Walk")
	simon.collision_layer ^= 2
	simon.collision_mask ^= 1
	simon.walkTo(exitPosition.global_position.x, funcref(self, "_doneExiting"))
	
func _doneExiting():
	simon.collision_layer ^= 2
	simon.collision_mask ^= 1
	simon.endCutscene()
	Globals.getGame().loadLevel("res://levels/Level6_2.tscn")

func _on_ExitArea_body_entered(body):
	simonExiting = true

func _on_DeathArea_body_entered(body):
	if body is Simon:
		body.position.y += 10000
		body.instaKill()
