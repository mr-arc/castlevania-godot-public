extends Node2D

onready var secretSpawner: = $Level5_1/SecretSpawner
onready var simon: = Globals.getSimon()
const SPAWN_SECRET_TIME = 2.0

var holdingRightTime = 0
var spawnedOneUp = false

func _physics_process(delta):
	if not spawnedOneUp:
		if Input.is_action_pressed("ui_right") and simon in secretSpawner.get_overlapping_bodies():
			holdingRightTime += delta
			if holdingRightTime >= SPAWN_SECRET_TIME:
				$Level5_1/HiddenTreasure.reveal()
				spawnedOneUp = true
		else:
			holdingRightTime = 0
