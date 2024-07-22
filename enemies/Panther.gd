extends KinematicBody2D
class_name Panther

const speed = 160
const gravity = 10
const jumpSpeed = -80
const REMOVE_OFFSET = 128

onready var animatedSprite: = $AnimatedSprite

var state = ASLEEP
var velocity: Vector2 = Vector2.ZERO

enum {
	ASLEEP,
	IDLE,
	RUNNING,
	LEAPING,
	FALLING,
}

func _ready():
	animatedSprite.play("Idle")

func _on_AttackRange_body_entered(body):
	if state == IDLE and body is Simon:
		print("panther is running")
		animatedSprite.play("Running")
		state = RUNNING
		
func _physics_process(delta):
	if state == IDLE or state == ASLEEP:
		return
	
	elif state == LEAPING:
		velocity = Vector2(speed * -animatedSprite.scale.x, jumpSpeed)
		velocity = move_and_slide(velocity, Vector2.UP)
		state = FALLING
		
	elif state == FALLING:
		velocity = Vector2(speed * -animatedSprite.scale.x, velocity.y + gravity)
		velocity = move_and_slide(velocity, Vector2.UP)
		if is_on_floor():
			animatedSprite.scale.x = -animatedSprite.scale.x
			animatedSprite.play("Running")
			state = RUNNING
	
	elif state == RUNNING:
		velocity = Vector2(speed * -animatedSprite.scale.x, velocity.y + gravity)
		velocity = move_and_slide(velocity, Vector2.UP)
		if not is_on_floor():
			animatedSprite.play("Leaping")
			state = LEAPING
		
		var xBounds = Globals.getVisibleXRange()
		if position.x < xBounds[0] - REMOVE_OFFSET or position.x > xBounds[1] + REMOVE_OFFSET:
			print("bye bye panther")
			queue_free()


func _on_VisibilityNotifier2D_screen_entered():
	if state == ASLEEP:
		state = IDLE
