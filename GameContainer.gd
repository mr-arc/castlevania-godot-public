extends Node2D

onready var viewBox = $ViewportContainer
onready var viewport = $ViewportContainer/Viewport
onready var screenSize = get_viewport().size

func _ready():
	# Seed the random number generator.
	randomize()
	var scaling = screenSize / viewport.size
	viewBox.rect_scale = scaling
	if Globals.isMobile:
		viewBox.rect_scale = Vector2(2, 2)
	$ViewportContainer/Viewport/Game.startLevel = load(Globals.startLevel)
	$ViewportContainer/Viewport/Game.start()
	
