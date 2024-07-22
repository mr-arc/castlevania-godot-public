extends StaticBody2D

export(PackedScene) var nextLevel
export(Vector2) var nextLevelPosition

onready var walkTo: = $WalkTo
onready var animatedSprite: = $AnimatedSprite
onready var audioPlayer: = $AudioStreamPlayer2D

var camera: Camera2D
var game: Game
var simon: Simon
var movingCamera = false
var newLevel: Node2D
	
func _physics_process(delta):
	if movingCamera:
		pass

func toggleOutsideBorderCollisionLayer(node: Node2D):
	var border = node.find_node("OutsideBorder", true, false)
	if border is StaticBody2D:
		border.collision_layer = border.collision_layer ^ 1
	
func _on_Area2D_body_entered(body):
	# If there's no level to load, just exit
	if not nextLevel:
		return
	simon = Globals.getSimon()
	game = Globals.getGame()
	camera = game.getCamera()
	
	game.followSimon = false
	simon.startCutscene("Idle")
	
	newLevel = nextLevel.instance()
	toggleOutsideBorderCollisionLayer(newLevel)
	
	newLevel.position = nextLevelPosition + game.levelScene.position
	yield(get_tree(), "idle_frame")
	game.makeCurrentLevel(nextLevel, newLevel)
	game.level.move_child(newLevel, 0)
	
	collision_mask = 0
	collision_layer = 0
	
	var cameraTween = get_tree().create_tween()
	var tweenTo = newLevel.position.x
	# If the door is facing the other way, we need to offset from the position.
	if scale.x < 0:
		tweenTo = global_position.x
	
	var pt = cameraTween.tween_property(
		camera, 
		"position", 
		Vector2(tweenTo, camera.position.y), 
		2)
	yield(pt, "finished")
	
	#open the door
	animatedSprite.play("Open")
	yield(animatedSprite, "animation_finished")
	audioPlayer.play()
	
	simon.walkTo(walkTo.global_position.x, funcref(self, "_doneWalking"))
	
func _doneWalking():
	var simon = Globals.getSimon()
	simon.setIdle()
	
	animatedSprite.play("Close")
	yield(animatedSprite, "animation_finished")
	audioPlayer.play()
	
	var cameraTween = get_tree().create_tween()
	var newCameraPos = camera.position.x + camera.get_viewport_rect().size.x/2
	# If we're facing the other way, we need to compute differently
	if scale.x < 0:
		# Plus 16 is because the position will be on the left side of the door
		newCameraPos = global_position.x - camera.get_viewport_rect().size.x/2 
		
	var pt = cameraTween.tween_property(
		camera, 
		"position", 
		Vector2(newCameraPos, camera.position.y), 
		2)
	yield(pt, "finished")
	toggleOutsideBorderCollisionLayer(newLevel)
	
	# kill the previous level
	var game = Globals.getGame()
	var oldLevel = game.level.get_child(game.level.get_child_count() - 1)
	Stats.levelEnd(oldLevel.get_node("LevelSetup").stage)
	oldLevel.queue_free()
	game.followSimon = true
	
	simon.endCutscene()	
	
	
	
