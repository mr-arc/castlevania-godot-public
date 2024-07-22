extends Node2D

const POINTS_POPUP: = preload("res://items/PointsPopup.tscn")

export(int) var points = 2000

onready var body: = $DropItem/RigidBody2D

func _on_DropItem_pickup():
	Globals.playSound(Globals.MONEY_PICKUP, body.global_position)
	Globals.getSimon().score += points
	var instance = POINTS_POPUP.instance()
	instance.points = points
	instance.set_position(body.position)
	get_parent().add_child(instance)
	queue_free()
