extends CPUParticles2D

onready var timer: = $Timer

func _ready():
	Globals.playSound(Globals.BLOCK_EXPLOSION, global_position)
	restart()
	timer.wait_time = lifetime
	timer.start()
	yield(timer, "timeout")
	queue_free()
