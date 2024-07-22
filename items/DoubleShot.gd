extends Node2D

func _on_DropItem_pickup():
	Globals.playSound(Globals.WEAPON_PICKUP, position)
	var simon = Globals.getSimon()
	if simon.weapon and simon.maxShots < 2:
		simon.maxShots = 2
	queue_free()
