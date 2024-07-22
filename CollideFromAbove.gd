extends StaticBody2D

onready var simon: = Globals.getSimon()
var rect: Rect2

func _ready():
	for child in get_children():
		if child is CollisionShape2D:
			var shape = child.shape as RectangleShape2D
			var pos = child.global_position
			var extents = shape.extents
			var start = Vector2(pos.x - extents.x, pos.y - extents.y)
			var end = Vector2(pos.x + extents.x, pos.y + extents.y)
			rect = Rect2(start, end - start)
			
func _physics_process(delta):
	var pos = simon.global_position
	if pos.x + 8 >= rect.position.x and pos.x - 8 <= rect.end.x and pos.y > rect.position.y:
		set_deferred("collision_layer", 64)
	else:
		set_deferred("collision_layer", 64 | 1)
