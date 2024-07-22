extends Node2D

signal pickedUp

onready var rigidBody: = $DropItem/RigidBody2D

func _on_Timer_timeout():
	rigidBody.mode = RigidBody2D.MODE_CHARACTER

func _on_DropItem_pickup():
	var simon = Globals.getSimon()
	simon.startCutscene()
	simon.animationPlayer.play("Idle")
	emit_signal("pickedUp")
	queue_free()
