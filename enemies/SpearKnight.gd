extends KinematicBody2D

export(int) var speed = 30

var minFlipSeconds = 1.0
var maxFlipSeconds = 4.0

onready var sprite: = $AnimatedSprite
onready var floorCheck: RayCast2D = $AnimatedSprite/FloorCheck
onready var flipTimer: = $FlipTimer

func flip():
	flipTimer.stop()
	sprite.scale.x *= -1
	flipTimer.wait_time = rand_range(minFlipSeconds, maxFlipSeconds)
	flipTimer.start()

func _physics_process(delta):
	move_and_slide(Vector2(speed * -sprite.scale.x, 98), Vector2.UP)
	if is_on_wall():
		flip()
	elif not floorCheck.is_colliding():
		flip()

func _on_FlipTimer_timeout():
	flip()
