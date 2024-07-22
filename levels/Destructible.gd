extends StaticBody2D
tool

signal destroyed(location)

export(String) var drop
export(Texture) var texture setget _setTexture, _getTexture

func _setTexture(value: Texture):
	texture = value
	$Sprite.texture = value
func _getTexture() -> Texture:
	return $Sprite.texture

func _on_Hitbox_hit(weapon: String):
	if weapon.begins_with("whip"):
		Items.spawnBlockExplosion(global_position)
		if drop:
			Items.spawn(drop, global_position)
		emit_signal("destroyed", global_position)
		queue_free()
#		
