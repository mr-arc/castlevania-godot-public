extends Area2D

signal hit

export(int) var speed = 90
var direction = -1
var hitEdge = false

func faceLeft():
	direction = -1
func faceRight():
	direction = 1
	
func _physics_process(delta):
	var xBounds = Globals.getVisibleXRange()
	position.x += speed * direction * delta
	if position.x < xBounds[0] or position.x > xBounds[1]:
		if hitEdge:
			queue_free()
		else:
			hitEdge = true
			direction = -direction

func _on_WeaponCross_area_entered(area):
	if area is Hitbox:
		area.emitHit("cross")
		emit_signal("hit")

func _on_WeaponCross_body_entered(body):
	# Simon catches it after it reflects.
	if hitEdge and (body is PhysicsBody2D):
		queue_free()
