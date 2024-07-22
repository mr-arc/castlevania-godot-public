extends Node2D

const FLASH_TIME = 0.06

onready var timer: = $Timer
onready var tween: = $Tween
onready var simon: = Globals.getSimon()

func _on_DropItem_pickup():
	Globals.playSound(Globals.WEAPON_PICKUP, position)
	visible = false
	
	var simon = Globals.getSimon()
	simon.increaseWhipLevel()
	
	get_tree().paused = true
	flash(3)
	
	
func flash(count):
	if count <= 0:
		simon.modulate = Color(1, 1, 1)
		get_tree().paused = false
		queue_free()
		return
		
	simon.modulate = Color(1, 0, 0)
	timer.wait_time = FLASH_TIME
	timer.start()
	yield(timer, "timeout")
	
	simon.modulate = Color(1, 1, 1)
	timer.wait_time = FLASH_TIME
	timer.start()
	yield(timer, "timeout")
	
	simon.modulate = Color(0, 0, 1)
	timer.wait_time = FLASH_TIME
	timer.start()
	yield(timer, "timeout")
	
	simon.modulate = Color(1, 1, 1)
	timer.wait_time = FLASH_TIME
	timer.start()
	yield(timer, "timeout")
	flash(count - 1)
		

func _on_MorningStar_tree_exiting():
	get_tree().paused = false
	simon.modulate = Color.white
