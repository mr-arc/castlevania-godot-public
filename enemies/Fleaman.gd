extends KinematicBody2D

enum State {
	CARRIED,
	DROPPING,
	IDLE,
	JUMPING,
	HOPPING,
	DECIDING,
}

const JUMP_VELOCITY = Vector2(70, -152)
const HOP_VELOCITY = Vector2(120, -55)

export(State) var state = State.IDLE
export(bool) var hopFirst = false
var gravity = 250
var hops = 0

onready var timer: = $Timer
onready var animatedSprite: = $AnimatedSprite
onready var simon: = Globals.getSimon()

var velocity = Vector2(0, gravity)
var onScreen = false

func _ready():
	animatedSprite.play("Idle")

func faceSimon():
	if simon.global_position.x < global_position.x:
		animatedSprite.scale.x = 1
	else:
		animatedSprite.scale.x = -1
		
func drop():
	state = State.DROPPING
	velocity = Vector2.ZERO

func _physics_process(delta):
	match state:
		State.CARRIED:
			return
			
		State.DROPPING:
			move_and_slide(velocity, Vector2.UP)
			velocity.y += gravity * delta
			if is_on_floor():
				decide()
			
		State.IDLE:
			faceSimon()
		State.DECIDING:
			return
			
		State.HOPPING, State.JUMPING:
			velocity = move_and_slide(velocity, Vector2.UP)
			if is_on_floor():
				velocity = Vector2.ZERO
				faceSimon()
				decide()
			elif is_on_wall():
				# When we hit a wall, we juump off it the other direction
				animatedSprite.scale.x *= -1
				jump()
			else:
				velocity.y += gravity * delta
			
	
func jump():
	state = State.JUMPING
	animatedSprite.play("Jumping")
	velocity = JUMP_VELOCITY * Vector2(-animatedSprite.scale.x, 1)
	
	
func hop():
	hops -= 1
	state = State.HOPPING
	animatedSprite.play("Jumping")
	velocity = HOP_VELOCITY * Vector2(-animatedSprite.scale.x, 1)
	
func decide():
	var prevState = state
	state = State.DECIDING
	animatedSprite.play("Idle")
	faceSimon()
	
	timer.wait_time = rand_range(0.04, 0.25)
	timer.start()
	yield(timer, "timeout")
	faceSimon()
	
	# He liks to hop multiple times in a row, so we see if there are any hops remaining
	if hops > 0:
		hop()
	else:
		var randNum = randi() % 10
		# Bias towards jumping if we just hopped
		if prevState == State.HOPPING:
			randNum += 3
		if randNum < 5:
			hops = randi() % 3 + 1
			hop()
		else:
			jump()
	
func _on_SimonDetector_body_entered(body):
	if state == State.CARRIED or state == State.DROPPING:
		return
		
	if hopFirst:
		hop()
	else:
		jump()


func _on_VisibilityNotifier2D_screen_entered():
	onScreen = true
	
func _on_VisibilityNotifier2D_screen_exited():
	if state == State.CARRIED or state == State.DROPPING:
		return
	if onScreen:
		queue_free()
