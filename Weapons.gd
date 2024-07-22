extends Reference
class_name Weapons

const weaponDagger: = preload("res://items/WeaponDagger.tscn")

static func fireDagger(simon: Node2D) -> void:
	var instance = weaponDagger.instance()
	
