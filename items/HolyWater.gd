extends Node2D

func _on_DropItem_pickup():
	Globals.playSound(Globals.WEAPON_PICKUP, position)
	Globals.getSimon().setWeapon("holywater")
	queue_free()
