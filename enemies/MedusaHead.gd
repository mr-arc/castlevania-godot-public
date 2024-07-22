extends Node2D

export(float) var ttl = 2

onready var startPosition = position
onready var killTimer: = $KillTimer
const FREQUENCY = 3.0
const MAGNITUDE = 40.0
const SPEED = 70.0

var time = 0

func faceLeft():
	scale.x = 1
func faceRight():
	scale.x = -1
	
func resetStartPosition():
	startPosition = position

func _physics_process(delta):
	time += delta
	position = startPosition + Vector2.UP * sin(time * FREQUENCY) * MAGNITUDE + Vector2(SPEED * -scale.x * time, 0)
	
func _on_VisibilityNotifier2D_screen_entered():
	killTimer.stop()
	
func _on_VisibilityNotifier2D_screen_exited():
	killTimer.wait_time = ttl
	killTimer.start()

func _on_KillTimer_timeout():
	queue_free()
