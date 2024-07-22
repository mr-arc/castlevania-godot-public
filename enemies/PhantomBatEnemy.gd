extends Node2D

onready var bat: = $PhantomBat
onready var timer: = $Timer
var awake = false


func _on_VisibilityNotifier2D_screen_entered():
	if not awake:
		awake = true
		bat.wakeUp()
	timer.stop()


func _on_VisibilityNotifier2D_screen_exited():
	if awake:
		timer.start()


func _on_Timer_timeout():
	# Delete the bat if they're off screen long enough.
	queue_free()
