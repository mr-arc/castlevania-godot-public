extends Node2D
tool
class_name DropItem

export(int) var frame setget setFrame, getFrame
export(bool) var autostartTtl = true setget _setAutostartTtl, _getAutostartTtl
signal pickup

func _setAutostartTtl(value):
	autostartTtl = value
	$TimeToLive.autostart = value
	if not $TimeToLive.is_stopped():
		$TimeToLive.stop()
func _getAutostartTtl():
	return $TimeToLive.autostart

func setFrame(value):
	frame = value
	if has_node("RigidBody2D/Sprite"):
		$RigidBody2D/Sprite.frame = value
	
func getFrame():
	if has_node("RigidBody2D/Sprite"):
		return $RigidBody2D/Sprite.frame
	return frame
	
func startTtl():
	$TimeToLive.start()
	
func _ready():
	$RigidBody2D/Sprite.frame = frame
	$TimeToLive.autostart = autostartTtl
	
func _on_PickupArea_body_entered(body):
	emit_signal("pickup")

func _on_TimeToLive_timeout():
	# Assume this is one level deep and remove its parent.
	get_parent().queue_free()
