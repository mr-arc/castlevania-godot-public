extends Node2D

const FIREBALL: = preload("res://enemies/Fireball.tscn")

onready var simon: = Globals.getSimon()
onready var visibilityNotifier: = $VisibilityNotifier2D
onready var animationPlayer: = $AnimationPlayer
onready var shotTimer: = $ShotTimer
onready var topMouth: = $Sprite/TopMouth
onready var bottomMouth: = $Sprite/BottomMouth

export(float) var minShotTime = 1.0
export(float) var maxShotTime = 3.0
export(int) var direction = -1 setget _setDirection, _getDirection

var isShooting = false

func _setDirection(value: int):
	direction = value
	$Sprite.scale.x = -sign(direction) 
func _getDirection():
	return -sign($Sprite.scale.x)

func _ready():
	_setDirection(direction)

func _process(delta: float):
	if not visibilityNotifier.is_on_screen():
		return
		
	if isShooting:
		return
	
	isShooting = true
	var shotTime = rand_range(minShotTime, maxShotTime)
	shotTimer.start()
	yield(shotTimer, "timeout")
	shoot()
	
func shoot():
	var dir = _getDirection()
	var anim: String
	if simon.global_position.x < global_position.x:
		anim = "ShootLeft" if dir < 0 else "ShootRight"
	else:
		anim = "ShootRight" if dir < 0 else "ShootLeft"
	animationPlayer.play(anim)
	yield(animationPlayer, "animation_finished")
	isShooting = false
		
func fireLeft():
	var fireball = FIREBALL.instance()
	fireball.direction = Vector2(_getDirection(), 0)
	owner.add_child(fireball)
	fireball.global_position = topMouth.global_position
	
func fireRight():
	var fireball = FIREBALL.instance()
	fireball.direction = Vector2(-_getDirection(), 0)
	owner.add_child(fireball)
	fireball.global_position = bottomMouth.global_position
