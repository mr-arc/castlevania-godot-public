extends KinematicBody2D

onready var camera: = $Camera2D
onready var collisionShape: = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var rect = collisionShape.shape as RectangleShape2D
	var viewport = camera.get_viewport_rect()
	rect.extents = viewport.size


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
