extends Area2D

const GHOST = preload("res://enemies/Ghost.tscn")

onready var simon = Globals.getSimon()

func _on_GhostSpawner_body_entered(body):
	if not (body is Simon):
		return
		
	# Ignore if there's already a ghost
	for child in get_children():
		if child is Ghost:
			return
	
	yield(get_tree(), "idle_frame")
	var ghost = GHOST.instance()
	add_child(ghost)
	ghost.global_position = simon.global_position  - Vector2(64, -16) * simon.getFacing()

func removeAllGhosts():
	for child in get_children():
		if child is Ghost:
			child.queue_free()
