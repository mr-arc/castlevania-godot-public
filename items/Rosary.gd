extends Node2D

const ROSARY_SHADER = preload("res://shaders/RosaryFlash.tres")

onready var timer: = $Timer

func _on_DropItem_pickup():
	Globals.playSound(Globals.ROSARY_PICKUP, global_position)
	var camX = Globals.getVisibleXRange()
	var camY = Globals.getVisibleYRange()
	
	# Give us a little extra than the screen
	camX[0] -= 8
	camX[1] += 8
	
	for node in get_tree().get_nodes_in_group("AffectedByRosary"):
		var pos = node.global_position
		
		if pos.x >= camX[0] and pos.x <= camX[1] and pos.y >= camY[0] and pos.y <= camY[1]:
			# If there's an enemy node, use it to determine the drop
			var drop = Items.ENEMY
			var enemy = Enemy.findEnemy(node)
			if enemy and enemy.drop:
				drop = enemy.drop
			# offset the explosion slightly so it doesn't stay on the floor
			Globals.explodeNode(node, pos + Vector2(0, -12), drop, true)
			
	var viewportContainer = Globals.getViewportContainer()
	$DropItem.visible = false
	flashThenFree(5, viewportContainer)

const FLASH_TIME = 0.05
func flashThenFree(flashes: int, viewportContainer: ViewportContainer):
	if flashes <= 0:
		viewportContainer.material = null
		queue_free()
		return
	viewportContainer.material = ROSARY_SHADER
	timer.wait_time = FLASH_TIME
	timer.start()
	yield(timer, "timeout")
	viewportContainer.material = null
	timer.wait_time = FLASH_TIME
	timer.start()
	yield(timer, "timeout")
	flashThenFree(flashes - 1, viewportContainer)


func _on_Rosary_tree_exiting():
	# If we pick up 2 at the same time, we'll get some weird flashing, so when it
	# exits, be sure to clear the shader.
	Globals.getViewportContainer().material = null
