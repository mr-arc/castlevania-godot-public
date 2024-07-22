extends Node2D

onready var secretTimer: = $SecretArea/SecretTimer

func _on_SecretTimer_timeout():
	$Level2_2/HiddenTreasure.reveal()
	
func _on_SecretArea_body_entered(body):
	secretTimer.start()

func _on_SecretArea_body_exited(body):
	secretTimer.stop()

func _on_Pit_body_entered(body):	
	if body is Simon:
		body.position.y += 5000
		body.instaKill()
		
