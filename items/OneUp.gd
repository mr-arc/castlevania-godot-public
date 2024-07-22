extends Node2D


func _on_DropItem_pickup():
	Globals.getSimon().grantExtraLife()
	queue_free()
