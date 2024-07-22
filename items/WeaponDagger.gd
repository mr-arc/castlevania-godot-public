extends Sprite

signal hit

const SPEED = 140

# Pixels off screen the projectile must be before we remove it.
const OFFSCREEN_PADDING = 16

func faceLeft():
	scale.x = 1
func faceRight():
	scale.x = -1

func _physics_process(delta):
	position.x += SPEED * -scale.x * delta
	var edges = Globals.getVisibleXRange()
	if (global_position.x < edges[0] - OFFSCREEN_PADDING 
			or global_position.x > edges[1] + OFFSCREEN_PADDING):
		queue_free()
	
func _on_Area2D_area_entered(area):
	if area is Hitbox:
		area.emitHit(Items.DAGGER)
		emit_signal("hit")
		queue_free()

func _on_WeaponDagger_tree_entered():
	Globals.playSound(Globals.DAGGER_THROW, global_position)
