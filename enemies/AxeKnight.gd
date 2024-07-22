extends KinematicBody2D
class_name AxeKnight

const SPEED = 65
const EVIL_AXE = preload("res://enemies/EvilAxe.tscn")
const MIN_MOVE_TIME = 0.1
const MAX_MOVE_TIME = 0.25
const MIN_SHOT_TIME = 2
const MAX_SHOT_TIME = 4

export(int) var direction = 1 setget _setDirection, _getDirection

onready var simon: = Globals.getSimon()
onready var simonTooClose: = $Sprite/AnimatedSprite/SimonTooClose
onready var moveTimer: = $MoveTimer
onready var shootTimer: = $ShootTimer
onready var floorDetectFront: = $Sprite/AnimatedSprite/FloorDetectFront
onready var floorDetectRear: = $Sprite/AnimatedSprite/FloorDetectRear
onready var sprite: = $Sprite

enum State {
	ASLEEP,
	MOVING,
	STOPPED
}
var state = State.ASLEEP
var velocity: = Vector2.ZERO

func _setDirection(value: int):
	var s = -sign(value)
	$Sprite.scale.x = s if s != 0 else 1
func _getDirection():
	return -sign($Sprite.scale.x)
	
func _physics_process(delta):
	if state != State.MOVING:
		return
	move_and_slide(velocity, Vector2.UP)
	# Change direction if we hit a wall.
	if is_on_wall():
		velocity.x *= -1
	elif sign(_getDirection()) == sign(velocity.x) and not floorDetectFront.is_colliding():
		velocity.x *= -1
	elif sign(_getDirection()) != sign(velocity.x) and not floorDetectRear.is_colliding():
		velocity.x *= -1
	
func wakeUp():
	shootTimer.wait_time = rand_range(MIN_SHOT_TIME, MAX_SHOT_TIME)
	shootTimer.start()
	decide()
	
func moveForward():
	move(_getDirection())
	
func moveAway():
	move(-_getDirection())
	
	
func move(direction):
	state = State.MOVING
	velocity = Vector2(SPEED * sign(direction), 0)
	moveTimer.wait_time = rand_range(MIN_MOVE_TIME, MAX_MOVE_TIME)
	moveTimer.start()
	yield(moveTimer, "timeout")
	stop()

func stop():
	state = State.STOPPED
	# If simon is behind us, we turn around.
	_setDirection(simon.global_position.x - global_position.x)
	velocity = Vector2.ZERO
	moveTimer.wait_time = rand_range(MIN_MOVE_TIME, MAX_MOVE_TIME)
	moveTimer.start()
	yield(moveTimer, "timeout")
	decide()
	
	
func decide():
	if isSimonTooClose():
		moveAway()
	else:
		var r = randf()
		# usually move towards
		if r < 0.8:
			moveForward()
		else:
			moveAway()
			
	
func isSimonTooClose() -> bool:
	return simonTooClose.overlaps_body(simon)
	
func fire(startPosition: Position2D):
	var axe = EVIL_AXE.instance()
	axe.direction = _getDirection()
	axe.thrower = self
	get_parent().add_child(axe)
	axe.global_position = startPosition.global_position
	axe.start()
	shootTimer.wait_time = rand_range(MIN_SHOT_TIME, MAX_SHOT_TIME)
	shootTimer.start()


func _on_VisibilityNotifier2D_screen_entered():
	wakeUp()

func _on_ShootTimer_timeout():
	if randi() % 2 == 0:
		fire($Sprite/AnimatedSprite/ThrowTop)
	else:
		fire($Sprite/AnimatedSprite/ThrowBottom)
