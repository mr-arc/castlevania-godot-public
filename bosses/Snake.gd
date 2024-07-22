extends KinematicBody2D
class_name Snake

const speed = 108
const gravity = 300

onready var sprite: = $AnimatedSprite
onready var simon: = Globals.getSimon()

var velocity = Vector2.ZERO

func faceLeft():
	sprite.scale.x = 1
func faceRight():
	sprite.scale.x = -1

func _physics_process(delta):
	if not is_on_floor():
		velocity = Vector2(0, velocity.y + gravity * delta)
	else:
		velocity = Vector2(-sprite.scale.x * speed, 0)
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
