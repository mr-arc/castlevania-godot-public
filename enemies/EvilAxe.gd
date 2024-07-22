extends Node2D

const RANGE = 128
const SPEED = 80

var startX: float
var endX
export(int) var direction = 1
var thrower: Node

var returning = false

var velocity = Vector2.ZERO

func start():
	startX = global_position.x
	velocity = Vector2(direction * SPEED, 0)
	endX = startX + RANGE * direction

func _physics_process(delta):
	position += velocity * delta
	if (direction > 0 and global_position.x >= endX) or (direction < 0 and global_position.x <= endX):
		returning = true
		velocity.x *= -1
	
func _on_VisibilityNotifier2D_screen_exited():
	# Remove if it goes offscreen after having reflected
	if returning:
		queue_free()


func _on_Hitbox_body_entered(body):
	if returning and body == thrower:
		queue_free()
