extends Node2D

onready var hitbox: = $Hitbox
onready var timer: = $Timer
onready var simon: = Globals.getSimon()

const SPEED = 50

var destination: Vector2

enum State {
	SPAWNING,
	MOVING,
	WAITING
}
var state = State.SPAWNING
var velocity: Vector2

func _ready():
	hitbox.collision_mask = 4
	
func _physics_process(delta):
	if state != State.MOVING:
		return
	
	var distanceBefore = global_position.distance_squared_to(destination)
	position += velocity * delta
	var distanceAfter = global_position.distance_squared_to(destination)
	# If we passed the destination, just stop.
	if distanceBefore < distanceAfter:
		state = State.WAITING
		timer.start()
	
func spawnComplete():
	hitbox.collision_mask = 2 | 4
	timer.start()
	state = State.WAITING

func _on_Timer_timeout():
	# Move toward simon
	var dir = global_position.direction_to(simon.global_position)
	var distance = global_position.distance_to(simon.global_position)
	# Move to simon, plus some
	destination = dir * distance + dir * rand_range(distance/4, distance)
	velocity = dir * SPEED
	state = State.MOVING


func _on_VisibilityNotifier2D_screen_exited():
	# remove the scythe if it flies off screen
	queue_free()
