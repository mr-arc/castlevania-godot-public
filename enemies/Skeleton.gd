extends KinematicBody2D

const BONE = preload("res://enemies/Bone.tscn")
const MIN_BONE_TIME = 0.33
const MAX_BONE_TIME = 2.8

const TIME_BETWEEN_MOVES = 0.15

onready var boneTimer: = $BoneTimer
onready var simon: = Globals.getSimon()
onready var animatedSprite: = $AnimatedSprite
onready var timer: = $Timer
var state

enum State {
	IDLE,
	JUMPING,
	HOPPING_BACK,
	HOPPING_FORWARD,
	STOPPED,
}

var velocity = Vector2.ZERO

func _physics_process(delta):
	move_and_slide(velocity, Vector2.UP)
	if not is_on_floor():
		velocity += Vector2(0, Globals.GRAVITY * delta)
	elif state == State.JUMPING:
		decide()

func wakeUp():
	decide()
	resetBoneTimer()
	
func jump():
	state = State.JUMPING
	faceSimon()
	velocity = Vector2(45 * -animatedSprite.scale.x, -260)

func stop():
	state = State.STOPPED
	faceSimon()
	velocity.x = 0
	timer.wait_time = TIME_BETWEEN_MOVES
	timer.start()
	yield(timer, "timeout")
	decide()
	
func hopBack():
	state = State.HOPPING_BACK
	faceSimon()
	velocity = Vector2(90 * animatedSprite.scale.x, 0)
	timer.wait_time = TIME_BETWEEN_MOVES
	timer.start()
	yield(timer, "timeout")
	stop()
	
func hopForward():
	state = State.HOPPING_FORWARD
	faceSimon()
	velocity = Vector2(90 * -animatedSprite.scale.x, 0)
	timer.wait_time = TIME_BETWEEN_MOVES
	timer.start()
	yield(timer, "timeout")
	stop()
	
func decide():
	var rnum = rand_range(0, 1)
	if not is_on_floor() or rnum < 0.2:
		stop()
		return
		
	var distance = abs(simon.global_position.distance_to(global_position))
	# If simon is far away, hop forward
	if distance > 120:
		if rnum < 0.75:
			hopForward()
		else:
			jump()
	elif distance < 60:
		# If simon is close, hop backward
		if rnum < 0.75:
			hopBack()
		else:
			jump()
	else:
		if rnum < 0.4:
			hopForward()
		elif rnum < 0.8:
			hopBack()
		else:
			jump()
	
func _on_BoneTimer_timeout():
	spawnBone()
	resetBoneTimer()
	
func resetBoneTimer():
	if state == State.IDLE:
		return
	var boneTime = rand_range(MIN_BONE_TIME, MAX_BONE_TIME)
	boneTimer.wait_time = boneTime
	boneTimer.start()
	
func faceSimon():
	animatedSprite.scale.x = -sign(global_position.direction_to(simon.global_position).x)

func _on_VisibilityNotifier2D_screen_entered():
	wakeUp()

func _on_VisibilityNotifier2D_screen_exited():
	state = State.IDLE
	
func spawnBone():
	var bone = BONE.instance()
	owner.add_child(bone)
	bone.global_position = global_position
	
	# apply some randomness to the bone's velocity
	var randVelocity = Vector2(rand_range(-5, 25) * -animatedSprite.scale.x, rand_range(-10, 5))
	var randTorque = rand_range(-10, 10)
	
	bone.linear_velocity.x *= -animatedSprite.scale.x
	bone.linear_velocity += randVelocity
	bone.angular_velocity += randTorque
