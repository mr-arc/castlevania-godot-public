extends Node2D

# Seconds to advance the first animation
export(float) var startHeight = 0
export(bool) var halfway = false
onready var animationPlayer: = $AnimationPlayer

var prefix = ""

func _ready():	
	if halfway:
		prefix = "Half"
	animationPlayer.play(prefix + "Rise")
	animationPlayer.advance(startHeight)

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name.ends_with("Fall"):
		animationPlayer.play(prefix + "Rise")
	else:
		animationPlayer.play(prefix + "Fall")
	
func _on_Hitbox_hit_simon():
	var simon = Globals.getSimon() as Simon
	if not simon.invincible:
		# HACK to fix double-kill bug
		# If simon is killed by a crusher, he will instantly die again upon respawning
		# So we double check the distance to him before issuing the kill command	
		var simonShape = simon.get_node("CollisionShape2D") as CollisionShape2D
		var myShape = $Teeth/Hitbox/CollisionShape2D as CollisionShape2D
		var simonShapePos = simonShape.global_position
		var myShapePos = myShape.global_position
		var distance = simonShapePos.distance_to(myShapePos)
		
		# If simon is more than 64 pixels away, he probably didn't get killed by this
		if distance > 64:
			print("simon would have died here")
			return
		
		print("crushed by %d" % get_instance_id())
		simon.instaKill("Crusher")
