extends Node2D

const SPLASH: = preload("res://Splash.tscn")

var simonInSecret = false
var secretRevealed = false
onready var simon = Globals.getSimon()
onready var hiddenTreasure: = $SecretArea/HiddenTreasure

func _process(delta):
	if simonInSecret and simon.isDucking and not secretRevealed:
		secretRevealed = true
		hiddenTreasure.reveal()

func _on_DeathArea_body_entered(body):
	_makeSplash(body.global_position)
	# move him offscreen
	body.position.y += 8000
	
	if body is Simon:
		body.instaKill()
	else:
		body.queue_free()

func _makeSplash(location: Vector2):
	var splash = SPLASH.instance()
	add_child(splash)
	splash.global_position = location
	splash.restart()

func _on_SecretArea_body_entered(body):
	if body is Simon:
		simonInSecret = true

func _on_SecretArea_body_exited(body):
	if body is Simon:
		simonInSecret = false
