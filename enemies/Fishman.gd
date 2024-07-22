extends KinematicBody2D

enum State {
	LEAPING,
	WALKING,
	SHOOTING,
	IDLE,
}

const FIREBALL = preload("res://enemies/Fireball.tscn")

onready var sprite: = $Sprite
onready var animationPlayer: = $AnimationPlayer
onready var mouth: = $Mouth
onready var timer: = $WalkTimer
onready var visibilityTimer: = $VisibilityTimer
onready var visibilityNotifier: = $VisibilityNotifier2D

const SPEED = 30
const LEAP_VELOCITY = 400
const GRAVITY = 9.8

var state = State.IDLE
var shootAsap = false

const COLLISION_MASK = 1
const COLLISION_LAYER = 8
var velocity: = Vector2.ZERO

func faceLeft():
	$Sprite.scale.x = 1
func faceRight():
	$Sprite.scale.x = -1
	
func leap():
	collision_layer = 0
	collision_mask = 0
	state = State.LEAPING
	$AnimationPlayer.play("Idle")
	velocity.y = -LEAP_VELOCITY
	
func _physics_process(delta):
	if is_on_floor() and shootAsap:
		shoot()
		
	match state:
		State.LEAPING:
			if is_on_floor():
				var simon = Globals.getSimon()
				if simon.global_position.x < global_position.x:
					faceLeft()
				else:
					faceRight()
				state = State.WALKING
				animationPlayer.play("Walk")
				timer.start()
			elif velocity.y > 0:
				collision_layer = COLLISION_LAYER
				collision_mask = COLLISION_MASK
		State.WALKING:
			if is_on_wall():
				sprite.scale.x *= -1
				
			if is_on_floor():
				velocity = Vector2(SPEED * -sprite.scale.x, 0)
			else:
				velocity = Vector2(0, velocity.y)
				
		State.SHOOTING:
			velocity = Vector2.ZERO
		
	velocity = move_and_slide(velocity + Vector2(0, GRAVITY), Vector2.UP)
	
func shoot():
	shootAsap = false
	var shot = FIREBALL.instance()
	if sprite.scale.x == 1:
		shot.faceLeft()
	else:
		shot.faceRight()
	Globals.getGame().add_child(shot)
	shot.global_position = mouth.global_position
	state = State.SHOOTING
	animationPlayer.play("Shoot")
	yield(animationPlayer, "animation_finished")
	var simon = Globals.getSimon()
	state = State.WALKING
	animationPlayer.play("Walk")
	timer.start()
	if simon.global_position.x < global_position.x:
		faceLeft()
	else:
		faceRight()

func _on_WalkTimer_timeout():
	shootAsap = true

func _on_VisibilityNotifier2D_screen_exited():
	if not visibilityTimer.is_inside_tree():
		return
	visibilityTimer.start()
	yield(visibilityTimer, "timeout")
	if not visibilityNotifier.is_on_screen():
		queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	visibilityTimer.stop()
