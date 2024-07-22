extends Node2D
class_name Fireball

onready var sprite: = $Sprite

export(int) var speed = 110
export(Vector2) var direction = Vector2.ZERO
export(int) var damage setget _setDamage, _getDamage

func _setDamage(value: int):
	$Enemy.damage = value
func _getDamage():
	return $Enemy.damage

func faceLeft():
	$Sprite.scale.x = 1
func faceRight():
	$Sprite.scale.x = -1
	
func _process(delta):
	if direction.length_squared() != 0:
		rotation = direction.angle() + PI
		position += speed * direction * delta
	else:	
		position.x += speed * -sprite.scale.x * delta
