extends KinematicBody2D

const SCYTHE: = preload("res://bosses/Scythe.tscn")
const MIN_SCYTHE_DISTANCE = 48

onready var sprite: = $Sprite
onready var simon: = Globals.getSimon()
onready var timer: = $Timer
onready var simonDetector: = $SimonDetector
onready var scytheTimer: = $ScytheTimer

const GRAVITY = 100
const BIG_JUMP_POWER = 120
const SMALL_JUMP_POWER = 70
const MIN_WAIT = 0.2
const MAX_WAIT = 3.0
const MAX_SCYTHES = 4

signal dead
signal damaged(maxHealth, healthRemaining)

enum State {
	ASLEEP,
	MOVING,
	STOPPED,
}
var state = State.ASLEEP
var velocity: Vector2 = Vector2.ZERO
var maxHealth: int

func _ready():
	maxHealth = $Enemy.weakHits

func wakeUp():
	scytheTimer.start()
	stop()

func stop():
	state = State.STOPPED
	# Move right now if simon is near.
	if simonDetector.overlaps_body(simon):
		move()
		return
		
	timer.wait_time = rand_range(MIN_WAIT, MAX_WAIT)
	timer.start()
	yield(timer, "timeout")
	move()
	
func move():
	state = State.MOVING
	var jumpPower = BIG_JUMP_POWER
	if not simonDetector.overlaps_body(simon):
		# If simon isn't close, we might hope (2/3 of the time
		if randi() % 3 < 1:
			jumpPower = SMALL_JUMP_POWER
	# Jump in a random direction
	var direction = 1 if randi() % 2 == 0 else -1
	velocity = Vector2(30 * direction, -jumpPower)
	
func _physics_process(delta):
	if state == State.ASLEEP or state == State.STOPPED:
		return
		
	sprite.scale.x = -sign(simon.global_position.x - global_position.x)
	move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		velocity = Vector2.ZERO
		stop()
	else:
		velocity.y += GRAVITY * delta
		
	if is_on_wall():
		velocity.x *= -1
		
func findScytheSpawnLocation(depth = 5) -> Vector2:
	if depth <= 0:
		# We tried 5 times, just spawn it below simon
		return simon.global_position + Vector2(0, 10)
	var xRange = Globals.getVisibleXRange()
	var yRange = Globals.getVisibleYRange()
	var x = rand_range(xRange[0], xRange[1])
	var y = rand_range(yRange[0], yRange[1])
	var location = Vector2(x, y)
	var distance = location.distance_to(simon.global_position)
	if distance < MIN_SCYTHE_DISTANCE:
		var dir = simon.global_position.direction_to(location)
		location *= dir * (MIN_SCYTHE_DISTANCE - distance)
	if location.x < xRange[0] or location.x > xRange[1] or location.y < yRange[0] or location.y > yRange[1]:
		return findScytheSpawnLocation(depth - 1)
	return location
		
func spawnScythe():
	var location = findScytheSpawnLocation()
	var scythe = SCYTHE.instance()
	get_parent().add_child(scythe)
	scythe.global_position = location
	
func _on_ScytheTimer_timeout():
	var count = len(get_tree().get_nodes_in_group("Scythe"))
	var numToSpawn = 0
	if count == 0:
		numToSpawn = 3
	elif count < MAX_SCYTHES:
		numToSpawn = 1
		
	for i in range(numToSpawn):
		spawnScythe()


func _on_Enemy_killed():
	# Destroy all the scythes when the reaper is killed.
	for scythe in get_tree().get_nodes_in_group("Scythe"):
		Globals.explodeNode(scythe, scythe.global_position, "", true)
	emit_signal("dead")
		
func _on_Enemy_damaged(healthRemaining):
	emit_signal("damaged", maxHealth, healthRemaining)



