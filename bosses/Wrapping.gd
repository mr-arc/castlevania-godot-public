extends AnimatedSprite

const FREQUENCY = 6.0
const MAGNITUDE = 18.0
const SPEED = 80.0

var time = 0
var startPosition

func storeStartPosition():
	startPosition = position

func face(direction: float):
	scale.x = -sign(direction)

func _physics_process(delta):
	time += delta
	position = startPosition + Vector2.UP * sin(time * FREQUENCY) * MAGNITUDE + Vector2(SPEED * -scale.x * time, 0)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
