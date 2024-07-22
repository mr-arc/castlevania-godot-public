extends Node2D

onready var timer: = $Timer
onready var dropItem: = $DropItem

func _on_DropItem_pickup():
	# TODO: Change so you become transparent, then apply the shader
	Globals.playSound(Globals.INVISIBILITY_PICKUP, position)
	Globals.getSimon().startInvisibility()
	dropItem.queue_free()
	timer.start()


func _on_Timer_timeout():
	var simon = Globals.getSimon()
	Globals.playSound(Globals.INVISIBILITY_OFF, simon.global_position)
	simon.stopInvisibility()
	queue_free()
