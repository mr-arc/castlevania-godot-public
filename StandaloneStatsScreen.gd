extends MarginContainer

var sceneChanging = false

func _ready():
	grab_focus()
	grab_click_focus()

func _gui_input(event):
	if ( (event is InputEventKey and event.is_pressed()) or
		(event is InputEventScreenTouch and event.pressed) or
		(event is InputEventMouseButton and event.is_pressed()) ):
		changeScene()
		
func _input(event):
	if event is InputEventKey and event.is_pressed():
		changeScene()
		
func changeScene():
	if not sceneChanging:
		sceneChanging = true
		Globals.changeScene("res://TitleScreen.tscn")
