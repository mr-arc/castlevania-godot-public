extends KinematicBody2D

signal killed
signal damaged(damage)

const SPEED = 60
const WRAPPING = preload("res://bosses/Wrapping.tscn")
const WRAPPING_SOUND = preload("res://sounds/19 - Mummy Wrapping.wav")
const EXPLOSION = preload("res://bosses/MummyExplosion.tscn")

onready var simon: = Globals.getSimon()
onready var hitbox: = $Hitbox
onready var timer: = $Timer
onready var animationPlayer: = $AnimationPlayer
onready var animatedSprite: = $AnimatedSprite

enum State {
	IDLE,
	WALKING,
	SHOOTING,
}
var state = State.IDLE

var velocity: Vector2
onready var maxHealth = $Enemy.weakHits
onready var prevHealth = maxHealth

func face(direction: float):
	animatedSprite.scale.x = -sign(direction)

func _ready():
	pass
	
func _physics_process(delta):
	if state != State.WALKING:
		return
		
	move_and_slide(velocity, Vector2.UP)
	# turn around when we hit a wall
	if is_on_wall():
		velocity.x *= -1
		animatedSprite.scale.x *= -1
		
func decide():
	var choice = randi() % 10
	
	if choice < 6:
		walk()
	else:
		shoot()
	
func shoot():
	state = State.SHOOTING
	animatedSprite.play("Idle")
	animationPlayer.play("Flash")
	yield(animationPlayer, "animation_finished")
	Globals.playSound(WRAPPING_SOUND, global_position)
	var wrapping = WRAPPING.instance()
	wrapping.face(-animatedSprite.scale.x)
	get_parent().add_child(wrapping)
	wrapping.global_position = global_position	
	wrapping.storeStartPosition()
	timer.wait_time = 0.3
	timer.start()
	yield(timer, "timeout")
	# Walk in opposite direction
	walk(animatedSprite.scale.x)
	
# Walks in the given direction. If a value is passed in, we use that direction
func walk(direction = 0):
	state = State.WALKING
	animatedSprite.play("Walking")
	if direction == 0:
		direction = 1 if randi() % 2 == 0 else -1
		# usually turn towards simon
		if randi() % 10 < 6:
			direction = sign(global_position.direction_to(simon.global_position).x)
	face(direction)
	velocity = Vector2(SPEED * direction, 0)
	var walkTime = rand_range(0.5, 1.4)
	timer.wait_time = walkTime
	timer.start()
	yield(timer, "timeout")
	decide()

func wakeUp():
	hitbox.monitorable = true
	hitbox.monitoring = true
	decide()

func _on_Enemy_damaged(healthRemaining):
	var damage = prevHealth - healthRemaining
	prevHealth = healthRemaining
	emit_signal("damaged", damage)


func _on_Enemy_killed():
	var explosion = EXPLOSION.instance()
	owner.add_child(explosion)
	explosion.global_position = global_position
	explosion.restart()
	
	emit_signal("killed")
