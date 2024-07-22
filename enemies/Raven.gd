extends AnimatedSprite

const MIN_FLY_TIME = 1.25
const MAX_FLY_TIME = 2.0
const BEELINE_ACCELERATION = 300

enum State {
	PERCHED,
	FLYING,
	HOVERING,
	BEELINING
}
var state = State.PERCHED

onready var timer: = $Timer
onready var simon: = Globals.getSimon()
onready var tween: = $Tween
onready var killTimer: = $KillTimer

var flyingTo: Vector2
var velocity: Vector2
var hovers: int = 0

func _physics_process(delta):
	if state == State.BEELINING:
		position += velocity * delta
		velocity.x += sign(velocity.x) * BEELINE_ACCELERATION * delta

func flyTo(location: Vector2):
	var initialDirectionToSimon = global_position.direction_to(simon.global_position)
	var flyTime = rand_range(MIN_FLY_TIME, MAX_FLY_TIME)
	tween.interpolate_property(
		self, "global_position", null, location, flyTime, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	var currentDirectionToSimon = global_position.direction_to(simon.global_position)
	# Most of  the time, if we've already hovered, do a beeline the opposite direction
	if (sign(initialDirectionToSimon.x) != sign(currentDirectionToSimon.x) 
			and hovers > 1 
			and	rand_range(0, 1.0) <= 0.85):
		beeline()
	else:
		hover()
	
func hover():
	hovers += 1
	faceSimon()
	timer.wait_time = rand_range(0.5, 1.8)
	timer.start()
	yield(timer, "timeout")
	flyPastSimon()
	
func flyPastSimon():
	var simonCenter = getSimonCenter()
	var direction = global_position.direction_to(simonCenter)
	var xOffset = randi() % 32 + 16
	var yOffset = randi() % 64 - 32
	var destination = simonCenter + Vector2(xOffset * sign(direction.x), yOffset)
	flyTo(destination)
	

func beeline():
	state = State.BEELINING
	faceSimon()
	var direction = global_position.direction_to(simon.global_position)
	velocity = Vector2(sign(direction.x), 0)
	
func _on_VisibilityNotifier2D_screen_entered():
	killTimer.stop()


func _on_VisibilityNotifier2D_screen_exited():
	if state == State.PERCHED:
		return
	killTimer.start()
	
func faceSimon():
	scale.x = -sign(global_position.direction_to(simon.global_position).x)
	
func getSimonCenter() -> Vector2:
	return simon.global_position + Vector2(0, -16)

func _on_KillTimer_timeout():
	queue_free()

func _on_SimonDetector_body_entered(body):
	faceSimon()
	timer.wait_time = 1
	timer.start()
	yield(timer, "timeout")
	play("Flying")
	var distance = global_position.distance_to(getSimonCenter())
	var destination = global_position + global_position.direction_to(getSimonCenter()) * distance / 2.0
	flyTo(destination)
