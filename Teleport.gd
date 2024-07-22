extends Area2D

signal teleported

enum Direction {
  GOING_DOWN, GOING_UP	
}

export(NodePath) var destinationNode
export(int) var newCameraY = Game.START_CAMERA_Y
export(Direction) var direction

func _physics_process(delta):
	if monitoring:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body is Simon:
				_teleport(body)
			
func _teleport(simon: Simon) -> void:
	match direction:
		Direction.GOING_DOWN:
			if not simon.isGoingDown():
				return
		Direction.GOING_UP:
			if not simon.isGoingUp():
				return
				
	var game = Globals.getGame()
	
	var newLocation = get_node(destinationNode).global_position
	game.cameraY = newCameraY + owner.global_position.y
	simon.set_deferred("position", newLocation)
	emit_signal("teleported")
