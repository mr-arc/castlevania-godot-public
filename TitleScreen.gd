extends TextureRect

var sceneChanging = false

onready var cheatCheckbox: = $CheatCheckbox
onready var fullScreenCheckbox: = $FullscreenCheckbox
onready var audioPlayer: = $AudioStreamPlayer

onready var focusables = [null, fullScreenCheckbox, cheatCheckbox]
var focusIndex = 0

func _ready():
	Stats.resetLocalStats()
	Stats.screenView("Title")

func _process(delta):
	if sceneChanging:
		return
		
	var direction = 0
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left"):
		direction = -1
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_right"):
		direction = 1
	
	if direction != 0:
		if focusables[focusIndex] and focusables[focusIndex].has_focus():
			focusables[focusIndex].release_focus()
			
		focusIndex = (focusIndex + direction) % len(focusables)
		if focusables[focusIndex]:
			focusables[focusIndex].grab_focus()
			
		
#		if not cheatCheckbox.has_focus():
#			cheatCheckbox.grab_focus()
#		else:
#			cheatCheckbox.release_focus()
	elif (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump") 
			or Input.is_action_just_pressed("ui_accept")):
		var checkbox = focusables[focusIndex] as CheckBox
		if checkbox:
			checkbox.pressed = not checkbox.pressed
		else:
			changeScene()

func _gui_input(event):
	if sceneChanging:
		return
		
#	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
#		changeScene()
		
func _unhandled_input(event):
	if sceneChanging:
		return
		
#	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
#		changeScene()
		
func changeScene():
	if sceneChanging:
		return
		
	sceneChanging = true
	Globals.changeScene("res://levels/TitleCutscene.tscn")
	
func openLevelSelect():
	sceneChanging = true
	audioPlayer.play()
	yield(audioPlayer, "finished")
	Globals.changeScene("res://LevelSelectScreen.tscn")


func _on_CheatCheckbox_toggled(button_pressed):
	Globals.cheatsEnabled = button_pressed


func _on_LevelSelectButton_gui_input(event):
	if sceneChanging:
		return
		
	if ((event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT)
	or (event is InputEventScreenTouch and event.pressed)):
		openLevelSelect()


func _on_FullscreenCheckbox_toggled(button_pressed):
	Globals.setFullscreen(button_pressed)
