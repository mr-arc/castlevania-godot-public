extends BitmapFont
tool

func _ready():
	add_texture(preload("res://textures/NES Font.png"))
	height = 8
	
	for i in range(13):
		add_char(ord("A") + i, 0, Rect2(i*8, 0, 8, 8))
