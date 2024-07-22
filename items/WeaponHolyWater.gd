extends RigidBody2D

signal hit

const THROW_FORCE = Vector2(90, -40)
const Y_OFFSET = -24
# Pixels off screen the projectile must be before we remove it.
const OFFSCREEN_PADDING = 16

onready var sprite: = $Sprite
onready var animationPlayer: = $AnimationPlayer
onready var damageShape: = $Area2D/DamageShape
onready var burningShape: = $Area2D/BurningShape

var isBurning = false
var affectedHitboxes = []

func faceLeft():
	$Sprite.scale.x = 1
func faceRight():
	$Sprite.scale.x = -1

func _physics_process(delta):
	var edges = Globals.getVisibleXRange()
	if (global_position.x < edges[0] - OFFSCREEN_PADDING 
			or global_position.x > edges[1] + OFFSCREEN_PADDING):
		queue_free()
	
func _on_WeaponHolyWater_tree_entered():
	apply_central_impulse(THROW_FORCE * Vector2(-$Sprite.scale.x, 1))

func _on_Area2D_area_entered(area):
	if area is Hitbox:
		# If we're burning, we save the hitbox to hit it again as the burn animates
		if isBurning:
			affectedHitboxes.append(weakref(area))
		area.emitHit(Items.HOLY_WATER)
		emit_signal("hit")

func _on_WeaponHolyWater_body_entered(body):
	# Check to make sure we're not already burning (if we hit 2 tiles at once)
	if isBurning:
		return
	isBurning = true
	call_deferred("_startBurning")
	
func _startBurning():
	mode = RigidBody2D.MODE_STATIC
	Globals.playSound(Globals.HOLY_WATER_BREAK, global_position)
	animationPlayer.play("Burning")
	burningShape.disabled = false
	damageShape.disabled = true
	yield(animationPlayer, "animation_finished")
	queue_free()
	
func _applyHits():
	# Applies another hit to anything still in contact.
	# These are weak references (they might already be dead)
	for ref in affectedHitboxes:
		var hitbox: Hitbox = ref.get_ref()
		if hitbox:
			hitbox.emitHit(Items.HOLY_WATER)
			emit_signal("hit")

