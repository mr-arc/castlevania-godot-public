extends RigidBody2D

signal hit

onready var audioStreamPlayer: = $AudioStreamPlayer2D
onready var animationPlayer: = $AnimationPlayer

func faceLeft():
	$Sprite.scale.x = 1
func faceRight():
	$Sprite.scale.x = -1

func _on_WeaponAxe_tree_entered():
	apply_central_impulse(Vector2(-$Sprite.scale.x * 130, -290))
	
func _process(delta):
	var yBounds = Globals.getVisibleYRange()
	# Remove if off-screen by more than 16 pixels
	if global_position.y > yBounds[1] + 16:
		queue_free()
		
func _fadeOut():
	animationPlayer.play("FadeOut")
	yield(animationPlayer, "animation_finished")
	queue_free()

func _on_HitArea_area_entered(area):
	if area is Hitbox:
		area.emitHit("axe")
		emit_signal("hit")
