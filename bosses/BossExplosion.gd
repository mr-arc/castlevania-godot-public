extends Node2D

const TILE_SIZE = 16.0
const MINI_EXPLOSION = preload("res://bosses/BossMiniExplosion.tscn")

onready var explosions = $Explosions
onready var particles = $Particles

export(int) var width = 3
export(int) var height = 3

func _ready():
	for i in range(width):
		for j in range(height):
			var ownerNode = Node2D.new()
			var instance = MINI_EXPLOSION.instance()
			ownerNode.add_child(instance)
			explosions.add_child(ownerNode)
			ownerNode.position = Vector2(i * TILE_SIZE, j * TILE_SIZE)
	# center the explosions
	explosions.position = Vector2(-TILE_SIZE * width / 2, -TILE_SIZE * height / 2)
	particles.restart()

func _on_TtlTimer_timeout():
	queue_free()
