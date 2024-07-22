extends KinematicBody2D

signal slam
signal dead
signal damaged(maxHealth, healthRemaining)

const FIREBALL = preload("res://enemies/Fireball.tscn")
const GRAVITY = 100
const JUMP_Y_POWER = 85
const JUMP_X_POWER = 40

onready var simon: = Globals.getSimon()
onready var firePosition: = $Sprite/FirePosition
onready var animationPlayer: = $AnimationPlayer
onready var timer: = $Timer
onready var sprite: = $Sprite

var velocity: Vector2 = Vector2.ZERO

enum State {
	WAITING,
	JUMP_PREP,
	JUMPING,
	LANDING,
	SHOOTING
}
var state = State.WAITING
var maxHealth: float

func _ready():
	modulate.a = 0
	maxHealth = $Enemy.weakHits
	$BirthExplosion.restart()
	timer.wait_time = 0.1
	timer.start()
	yield(timer, "timeout")
	modulate.a = 1
	wait()

func _physics_process(delta):	
	if state == State.JUMPING:
		move_and_slide(velocity, Vector2.UP)
		if is_on_floor():
			land()
		else:
			velocity.y += GRAVITY * delta
			
func wait():
	print("Waiting")
	faceSimon()
	state = State.WAITING
	animationPlayer.play("Idle")
	timer.wait_time = rand_range(1.0, 2.5)
	timer.start()
	yield(timer, "timeout")
	if randi() % 3 <= 1:
		jump()
	else:
		shoot()
		
func land():
	print("Landing")
	state = State.LANDING
	animationPlayer.play("Land")
	velocity.y = 0
	emit_signal("slam")
	yield(animationPlayer, "animation_finished")
	wait()
	
func shoot():
	print("Shooting")
	faceSimon()
	state = State.SHOOTING
	animationPlayer.play("Fire")
	yield(animationPlayer, "animation_finished")
	wait()
	
func jump():
	print("Jumping")
	state = State.JUMP_PREP
	animationPlayer.play("Jump")
	yield(animationPlayer, "animation_finished")
	state = State.JUMPING
	velocity = Vector2(-sprite.scale.x * JUMP_X_POWER, -JUMP_Y_POWER)
	
func faceSimon():
	sprite.scale.x = -sign(global_position.direction_to(simon.global_position).x)

func fire():
	var direction = firePosition.global_position.direction_to(simon.global_position + Vector2(0, -24))
	fireFireball(direction)
	fireFireball(direction.rotated(0.24))
	fireFireball(direction.rotated(-0.24))
	
func fireFireball(direction: Vector2):
	var fireball = FIREBALL.instance()
	fireball.damage = 4
	get_parent().add_child(fireball)
	fireball.direction = direction
	fireball.global_position = firePosition.global_position



func _on_Enemy_damaged(healthRemaining):
	emit_signal("damaged", maxHealth, healthRemaining)


func _on_Enemy_killed():
	emit_signal("dead")
