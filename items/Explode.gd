extends Node2D
class_name Explode

func _on_AnimatedSprite_animation_finished():
	queue_free()
