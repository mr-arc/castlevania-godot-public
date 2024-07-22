extends Node2D

func _on_DropItem_pickup():
	Globals.playSound(Globals.ITEM_PICKUP, position)
	Globals.getSimon().hearts += 5
	queue_free()
