extends AnimatedSprite

signal killed
signal damaged(healthRemaining)

const SNAKE = preload("res://bosses/Snake.tscn")

const MAX_SNAKES = 2
const MIN_SNAKE_TIME = 0.4
const MAX_SNAKE_TIME = 2.3

const MIN_MOVE_TIME = 0.33
const MAX_MOVE_TIME = 3.0

export(NodePath) var top: NodePath
export(NodePath) var bottom: NodePath

onready var snakeTimer: = $SnakeTimer
onready var moveTimer: = $MoveTimer
onready var simon: = Globals.getSimon()

onready var topPosition = get_node(top).global_position
onready var bottomPosition = get_node(bottom).global_position
onready var camera: Camera2D = Globals.getGame().getCamera()
onready var hitbox: = $Hitbox

enum State {
	IDLE,
	WAITING,
	MOVING
}
var state = State.IDLE
var velocity = Vector2.ZERO
var speed = 40

func getHealth():
	return $Enemy.weakHits

func _ready():
	hitbox.monitorable = false
	hitbox.monitoring = false
	play("Intro")
	yield(self, "animation_finished")
	wakeUp()
	
func _physics_process(delta):
	match state:
		State.WAITING:
			return
		State.MOVING:
			position = position + velocity * delta
			if global_position.y <= topPosition.y or global_position.y >= bottomPosition.y:
				velocity.y *= -1
			var xRange = Globals.getVisibleXRange()
			if global_position.x <= xRange[0] or global_position.x >= xRange[1]:
				velocity.x *= -1
				
func wakeUp():
	play("Active")
	snakeTimer.start()
	hitbox.monitorable = true
	hitbox.monitoring = true
	move()
	
			
func wait():
	state = State.WAITING
	moveTimer.wait_time = rand_range(MIN_MOVE_TIME, MAX_MOVE_TIME)
	moveTimer.start()
	yield(moveTimer, "timeout")
	move()
	
func move():
	state = State.MOVING
	var direction = Vector2.UP.rotated(rand_range(0, PI * 2))
	velocity = direction * speed
	
	moveTimer.wait_time = rand_range(MIN_MOVE_TIME, MAX_MOVE_TIME)
	moveTimer.start()
	yield(moveTimer, "timeout")
	wait()

func spawnSnake():
	var snake = SNAKE.instance()
	owner.add_child(snake)
	snake.global_position = global_position
	if simon.global_position.x < global_position.x:
		snake.faceLeft()
	else:
		snake.faceRight()
		
func getSnakeCount() -> int:
	var count = 0
	for child in owner.get_children():
		if child is Snake:
			count += 1
	return count

func startSnakeTimer():
	snakeTimer.wait_time = rand_range(MIN_SNAKE_TIME, MAX_SNAKE_TIME)
	snakeTimer.start()
	
func _on_SnakeTimer_timeout():
	# Check to see if snake limit is reached
	if getSnakeCount() < MAX_SNAKES:
		spawnSnake()
	startSnakeTimer()

func _on_Enemy_killed():
	emit_signal("killed")

func _on_Enemy_damaged(healthRemaining):
	emit_signal("damaged", healthRemaining)
