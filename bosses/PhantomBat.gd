extends Sprite
class_name PhantomBat

const MIN_WAIT = 0.5
const MAX_WAIT = 4
const HOVER_SPEED = 40
const SWOOP_SPEED = 120
const MIN_SWOOP_GRAVITY = -85
const MAX_SWOOP_GRAVITY = -60

const FIREBALL = preload("res://enemies/Fireball.tscn")

enum State {
	ASLEEP,
	HOVERING,
	SWOOPING,
	WAITING,
}

signal dead
signal damaged(maxHealth, healthRemaining)

onready var timer: = $Timer
onready var animationPlayer: = $AnimationPlayer

export(State) var state = State.ASLEEP
export(float) var fireballPercent = 0.25

var velocity = Vector2.ZERO
var swoopGravity: float
onready var maxHealth = $Enemy.weakHits
	

func _physics_process(delta):
	var camera = Globals.getGame().getCamera()
	var camXMin = camera.position.x - camera.get_viewport_rect().size.x / 2 + 16
	var camXMax = camera.position.x + camera.get_viewport_rect().size.x / 2  - 16
	var camYMin = camera.position.y - camera.get_viewport_rect().size.y / 2 + 64
	var camYMax = camera.position.y + camera.get_viewport_rect().size.y / 2  - 16
	
	match state:
		State.ASLEEP:
			pass
			
		State.HOVERING:
			var newPosition = global_position + velocity * delta
			if newPosition.x >= camXMax or newPosition.x <= camXMin:
				velocity.x *= -1
			if newPosition.y >= camYMax or newPosition.y <= camYMin:
				velocity.y *= -1
				
			position += velocity * delta
			
		State.SWOOPING:
			velocity.y += swoopGravity * delta
			var newPosition = global_position + velocity * delta
			if newPosition.x >= camXMax or newPosition.x <= camXMin:
				velocity.x *= -1
				
			if newPosition.y >= camYMax or newPosition.y <= camYMin:
				timer.stop()
				hover()
			else:
				position += velocity * delta
			
func wakeUp():
	if not state == State.ASLEEP:
		return
	animationPlayer.play("Awake")
	wait()
	
func wait():
	state = State.WAITING
	velocity = Vector2.ZERO
	timer.wait_time = _randomWaitTime()
	timer.start()
	yield(timer, "timeout")
	var choice = randi() % 2
	# do not swoop if we're below simon
	if choice == 0 or Globals.getSimon().global_position.y <= global_position.y:
		hover()
	else:
		swoop()
	
func hover():
	state = State.HOVERING
	var direction = _randomHoverDirection()
	velocity = direction * HOVER_SPEED
	timer.wait_time = _randomWaitTime()
	timer.start()
	yield(timer, "timeout")
	print("done hovering")
	
	#sometimes he will shoot a fireball
	var fireCheck = randf()
	if fireCheck <= fireballPercent:
		fire()
	wait()
	
func fire():
	var fireball = FIREBALL.instance()
	fireball.direction = global_position.direction_to(Globals.getSimon().global_position + Vector2(0, -16))
	Globals.getGame().add_child(fireball)
	fireball.global_position = global_position
	
func _randomHoverDirection() -> Vector2:
	var angle = rand_range(0, 2 * PI)
	return Vector2.UP.rotated(angle)
	
func swoop():
	print("start swoop")
	swoopGravity = rand_range(MIN_SWOOP_GRAVITY, MAX_SWOOP_GRAVITY)
	state = State.SWOOPING
	var simonLocation = Globals.getSimon().global_position
	velocity = global_position.direction_to(simonLocation) * SWOOP_SPEED
	timer.wait_time = _randomWaitTime()
	timer.start()
	yield(timer, "timeout")
	print("done swooping")
	wait()
		
func _randomWaitTime() -> float:
	return rand_range(MIN_WAIT, MAX_WAIT)
		
func _on_Enemy_killed():
	emit_signal("dead")

func _on_Enemy_damaged(healthRemaining):
	emit_signal("damaged", maxHealth, healthRemaining)
