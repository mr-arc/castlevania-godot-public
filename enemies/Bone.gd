extends RigidBody2D

onready var timer: = $Timer

func _on_Timer_timeout():
	queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	timer.stop()

func _on_VisibilityNotifier2D_screen_exited():
	timer.start()
