extends Node2D
tool

onready var revealSound: = $RevealSound
var dropItem: DropItem
var rigidBody: RigidBody2D
var pickupArea: Area2D
var isRevealed: = false

func _ready():
	if not Engine.editor_hint:
		_prepareTreasure()
	
func _prepareTreasure():
	var treasure = _getTreasure()
	
	# if treasure is a drop item, we need to change it to a static body
	dropItem = treasure.find_node("DropItem", true, false)
	if dropItem:
		dropItem.autostartTtl = false
		rigidBody = dropItem.find_node("RigidBody2D", true, false)
		rigidBody.mode = RigidBody2D.MODE_STATIC
		pickupArea = dropItem.find_node("PickupArea", true, false)
		pickupArea.collision_mask = 0
		
		
func _getTreasure() -> Node2D:
	return get_node("Treasure") as Node2D
	
func _get_configuration_warning():
	if _getTreasure() == null:
		return "Please include a child node named 'Treasure'."
	return ""

func reveal():
	isRevealed = true
	revealSound.play()
	var treasure = _getTreasure()
	var tween = get_tree().create_tween()
	var tweenTarget = treasure
	if pickupArea:
		pickupArea.collision_mask = 2
	if rigidBody:
		tweenTarget = rigidBody
	tween.tween_property(tweenTarget, "position", treasure.position + Vector2(0, -16), 1.2)
	
	yield(tween, "finished")
	if dropItem:
		dropItem.startTtl()
	
func _on_HiddenTreasure_child_entered_tree(node: Node):
	update_configuration_warning()
