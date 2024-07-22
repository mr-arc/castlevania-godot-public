extends Node2D
tool
class_name WeaponItem

export(String) var weapon;
export(int) var frame setget _setFrame, _getFrame;

func _setFrame(value):
	$DropItem.frame = value
func _getFrame():
	return $DropItem.frame

func _on_DropItem_pickup():
	Globals.playSound(Globals.WEAPON_PICKUP, global_position)
	Globals.getSimon().setWeapon(weapon)
	queue_free()
