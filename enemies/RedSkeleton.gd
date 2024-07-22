extends KinematicBody2D

onready var simon: = Globals.getSimon()
onready var sprites: = $Sprites
onready var standingSprite: = $Sprites/StandingSprite
onready var downSprite: = $Sprites/DownSprite
onready var timer: = $Timer
onready var hitShape: = $Hitbox/HitShape

const WALKING_SPEED = 40
enum State {
	ASLEEP,
	STOPPED,
	WALKING,
	DOWN,
	RISING
}
export(State) var state = State.ASLEEP
export(bool) var startDown = false
export(int) var direction = 1 setget _setDirection, _getDirection
var velocity = Vector2.ZERO

func _setDirection(dir: int):
	direction = dir
	$Sprites.scale.x = -sign(dir)
func _getDirection():
	return int(-sign($Sprites.scale.x))
	
func _ready():
	_setDirection(direction)
	if startDown:
		velocity = Vector2.ZERO
		standingSprite.visible = false
		downSprite.visible = true
		hitShape.set_deferred("disabled", true)
		downSprite.play("Down")
		
func _physics_process(delta):
	if state != State.WALKING:
		return
	move_and_slide(velocity, Vector2.UP)
	if is_on_wall():
		velocity.x *= -1
		sprites.scale.x *= -1

func _on_Hitbox_hit_simon():
	if state == State.ASLEEP: return
	if state != State.DOWN and state != State.RISING and not simon.invincible:
		simon.doDamage(4)

func _on_Hitbox_hit(weapon):
	if state == State.ASLEEP: return
	if state != State.DOWN and state != State.RISING:
		simon.score += 400
		Globals.playSound(Globals.WHIP_HIT, global_position)
		drop()
		
func wakeUp():
	if startDown:
		rise()
	else:		
		walk()

func drop(immediate: bool = false):
	Stats.kill("Red Skeleton", Globals.currentStage)
	state = State.DOWN
	velocity = Vector2.ZERO
	standingSprite.visible = false
	downSprite.visible = true
	hitShape.set_deferred("disabled", true)
	downSprite.play("Falling")
	timer.wait_time = 2
	timer.start()
	yield(timer, "timeout")
	rise()
	
	
func rise():
	state = State.RISING
	downSprite.play("Rising")
	yield(downSprite, "animation_finished")
	downSprite.visible = false
	standingSprite.visible = true
	hitShape.set_deferred("disabled", false)
	walk()
	
func stop():
	state = State.STOPPED
	standingSprite.play("Stopped")
	velocity = Vector2.ZERO
	timer.wait_time = 1
	timer.start()
	yield(timer, "timeout")
	walk()
	
	
func walk():
	state = State.WALKING
	standingSprite.play("Walking")
	velocity = Vector2(-sign(sprites.scale.x) * WALKING_SPEED, 0)
	timer.wait_time = 1
	timer.start()
	yield(timer, "timeout")
	stop()


func _on_VisibilityNotifier2D_screen_entered():
	if state == State.ASLEEP:
		wakeUp()
