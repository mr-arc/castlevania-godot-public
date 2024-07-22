extends Node2D

const DRAG = 50
var impulse = Vector2(30, 0)

onready var body: = $DropItem/RigidBody2D
onready var timer: = $Timer

func _on_DropItem_pickup():
	Globals.playSound(Globals.ITEM_PICKUP, position)
	Globals.getSimon().hearts += 1
	queue_free()
	
func _ready():
	flip()
	
func flip():
	body.apply_central_impulse(impulse)
	body.applied_force = Vector2(-sign(impulse.x) * DRAG, 0)
	impulse.x = -impulse.x
	
func _on_Timer_timeout():
	flip()
	
func _on_RigidBody2D_body_entered(body):
	call_deferred("stayStill")
	
func stayStill():
	# Stop the thing when it hits the ground
	timer.disconnect("timeout", self, "_on_Timer_timeout")
	timer.stop()
	body.mode =RigidBody2D.MODE_STATIC
