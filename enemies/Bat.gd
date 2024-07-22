extends Node2D

const Y_VARIANCE = 16

enum State {
	NONE,
	SEEKING,
	DOWN,
	UP
}

onready var sprite: = $AnimatedSprite
onready var deathTimer: = $DeathTimer
onready var simon = Globals.getSimon()

var minY: float = NAN
var maxY: float
export(String, "Blue", "Red") var color = "Red"
export(State) var state = State.DOWN
export(Vector2) var speed = Vector2(55, 16)

func faceLeft():
	$AnimatedSprite.scale.x = 1
func faceRight():
	$AnimatedSprite.scale.x = -1
	
func _ready():
	var animation = "Hanging" if state == State.NONE else "Flying"
	var a = "{0}{1}".format([color, animation])
	sprite.play(a)
	
func wakeUp():
	state = State.SEEKING
	sprite.play("{0}Flying".format([color]))
	if simon.global_position.x < global_position.x:
		faceLeft()
	else:
		faceRight()
		
func _physics_process(delta):
	if state == State.NONE:
		return
		
	if state == State.SEEKING:
		var velocity = global_position.direction_to(simon.global_position + Vector2(16, 0)) * speed.length()
		global_position += velocity * delta * Vector2(-sprite.scale.x, 1)
		return
		
	if is_nan(minY):
		minY = global_position.y
		maxY = minY + Y_VARIANCE
	
	var velocity = Vector2.ZERO
	if state != State.NONE:
		velocity = speed
		if state == State.DOWN:
			velocity.y *= 1
		elif state == State.UP:
			velocity.y *= -1
	global_position += velocity * delta * Vector2(-sprite.scale.x, 1)
	
	if state == State.DOWN and global_position.y > maxY:
		state = State.UP
	elif state == State.UP and global_position.y < minY:
		state = State.DOWN
	
func _on_VisibilityNotifier2D_screen_exited():
	if state == State.NONE:
		return
	# Once bat is offscreen for 1 second, remove it
	if not deathTimer.is_inside_tree():
		return
	deathTimer.start()
	yield(deathTimer, "timeout")
	queue_free()

func _on_SimonDetector_body_entered(body):
	if state == State.NONE and body is Simon:
		wakeUp()
		
