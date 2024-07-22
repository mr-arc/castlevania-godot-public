extends KinematicBody2D

export(int) var speed = 60

const MIN_MOVE_TIME = 0.2
const MAX_MOVE_TIME = 2.0

signal dead
signal damaged(maxHealth, healthRemaining)

onready var timer: = $Timer
onready var sprite: = $AnimatedSprite
onready var hitbox: = $Hitbox
onready var simon: = Globals.getSimon()

var maxHealth
var awake: = false
var velocity: = Vector2.ZERO

func _ready():
	maxHealth = $Enemy.weakHits
	hitbox.monitorable = false
	hitbox.monitoring = false

func wakeUp():
	awake = true
	hitbox.monitorable = true
	hitbox.monitoring = true
	decide()
	
func faceSimon():
	sprite.scale.x = sign(simon.global_position.direction_to(global_position).x)
	
func decide():
	var dir = 1.0 if randi() % 2 == 0 else -1.0
	velocity.x = speed * dir
	timer.wait_time = rand_range(MIN_MOVE_TIME, MAX_MOVE_TIME)
	timer.start()
	yield(timer, "timeout")
	decide()

func _physics_process(delta):
	faceSimon()
	
	if not awake:
		return
		
	move_and_slide(velocity, Vector2.UP)
	if is_on_wall():
		velocity.x *= -1


func _on_Enemy_damaged(healthRemaining):
	emit_signal("damaged", maxHealth, healthRemaining)


func _on_Enemy_killed():
	emit_signal("dead")
