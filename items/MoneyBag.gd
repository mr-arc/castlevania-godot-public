extends Node2D
class_name MoneyBag


onready var dropItem: = $DropItem
onready var body: = $DropItem/RigidBody2D
onready var pointsPopup: = preload("res://items/PointsPopup.tscn")
onready var animationPlayer: = $AnimationPlayer

enum MoneyType {RED, BLUE, YELLOW, FLASH}

export(int) var points = 100
export(MoneyType) var type = MoneyType.RED
export(bool) var autostartTtl = true setget _setAutostartTtl, _getAutostartTtl

func _setAutostartTtl(value):
	autostartTtl = value
	$DropItem.autostartTtl = value
func _getAutostartTtl():
	return $DropItem.autostartTtl
	
func _ready():
	$DropItem.autostartTtl = autostartTtl

func _process(delta):
	if type == MoneyType.FLASH:
		if not animationPlayer.is_playing():
			animationPlayer.play("Flashing")
		return
	var frame
	match type:
		MoneyType.RED:
			frame = 29
		MoneyType.BLUE:
			frame = 30
		MoneyType.YELLOW:
			frame = 31
	dropItem.frame = frame
	
func startTtl():
	$DropItem.startTtl()
	
func _on_DropItem_pickup():
	Globals.playSound(Globals.MONEY_PICKUP, body.global_position)
	Globals.getSimon().score += points
	
	# Replace with points popup
	var instance = pointsPopup.instance()
	instance.points = points
	
	get_parent().add_child(instance)
	instance.set_global_position(body.global_position)
	queue_free()
	
