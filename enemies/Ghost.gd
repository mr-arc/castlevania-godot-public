extends AnimatedSprite
class_name Ghost

export(int) var speed = 25
export(bool) var active = false
onready var simon: = Globals.getSimon()
onready var animationPlayer: = $AnimationPlayer

func _physics_process(delta):		
	if simon.global_position.x > global_position.x:
		scale.x = -1.0
	else:
		scale.x = 1.0
		
	var direction = global_position.direction_to(simon.global_position + Vector2(0, -16))
	position += Vector2(direction * speed * delta)
