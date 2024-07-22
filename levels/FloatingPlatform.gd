extends KinematicBody2D

onready var simon = Globals.getSimon()
onready var layer = collision_layer
onready var mask = collision_mask

func _process(delta):
	# If simon is below us, don't collide with him
	if global_position.y < simon.global_position.y:
		collision_layer = 0
		collision_mask = 0
	else:
		collision_layer = layer
		collision_mask = mask 
