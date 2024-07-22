extends Node2D

func _on_DropItem_pickup():
	Globals.playSound(Globals.WEAPON_PICKUP, position)
	var simon = Globals.getSimon()
	if simon.weapon and  simon.maxShots < 3:
		simon.maxShots = 3
	queue_free()
