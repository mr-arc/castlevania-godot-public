extends Node2D

onready var game: = Globals.getGame()
onready var animationPlayer: = $AnimationPlayer
onready var hiddenTreasure: = $HiddenTreasure
onready var simon: = Globals.getSimon()
onready var setup: = $LevelSetup

func _on_GoDown1_teleported():
	game.followSimon = false
	game.getCamera().position = setup.getResetCameraPosition()

func _on_GoUp1_teleported():
	game.followSimon = true

func _on_DeathArea_body_entered(body):
	if body is Simon:
		body.position.y += 100
		body.instaKill()

func _on_SecretArea_body_entered(body):
	# oneshot connection
	if body is Simon:
		hiddenTreasure.reveal()
		
