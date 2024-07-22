extends KinematicBody2D

onready var sprite: = $Sprite
export(int) var speed = 60
export(int) var direction = 1

func faceRight():
	direction = -1
	if sprite:
		sprite.scale.x = -1
func faceLeft():
	direction = 1
	if sprite:
		sprite.scale.x = 1
func flip():
	direction = -direction
	if sprite:
		sprite.scale.x = direction
	
func _ready():
	sprite.scale.x = direction

func _physics_process(delta):
	var velocity = Vector2(speed * -sprite.scale.x, Globals.GRAVITY)
	move_and_slide(velocity, Vector2.UP)
	if is_on_wall():
		flip()
	
