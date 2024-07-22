extends Area2D

class_name Hitbox

signal hit(weapon)
signal hit_simon

func emitHit(weapon):
	emit_signal("hit", weapon)

func _on_Hitbox_body_entered(body):
	if body.collision_layer == 2:
	  emit_signal("hit_simon")

