extends Node2D
class_name Whippable

export(String) var drop = "random";

onready var hitbox: Hitbox = $Hitbox

func _ready():
	hitbox.connect("hit", self, "_on_hit")

func _on_hit(weapon):
	Globals.explodeNode(self, global_position, drop)
