extends MarginContainer

const SELECT_SOUND = preload("res://sounds/06 - Ding ding.wav")
const GAME_SELECT_SOUND = preload("res://sounds/01 - Game Select.wav")

onready var continueSelector: = $"%ContinueSelector"
onready var gameOverSelector: = $"%GameOverSelector"
onready var audioPlayer: = $AudioStreamPlayer
onready var timer: = $Timer
onready var exitTimer: = $ExitTimer

onready var selectors = [continueSelector, gameOverSelector]
var selectedIndex = 0
var loading = false

func _ready():
	Stats.screenView("Game Over")
	selectors[1].modulate.a = 0
	MusicPlayer.playMusic("res://music/10 Game Over.mp3", false)

func _process(delta):
	if loading:
		return
		
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		toggleSelection()
	elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept"):
		activate()	
		
func activate():
	loading = true
	audioPlayer.stream = GAME_SELECT_SOUND
	audioPlayer.play()
	startFlashing()
	exitTimer.start()
	yield(exitTimer, "timeout")
	if selectedIndex == 0:
		continueGame()
	else:
		Globals.changeScene("res://TitleScreen.tscn")
		
func startFlashing():
	selectors[selectedIndex].modulate.a = abs(selectors[selectedIndex].modulate.a - 1)
	timer.start()
	yield(timer, "timeout")
	startFlashing()
		
func continueGame():
	var levelToLoad: String
	
	if Globals.currentStage <= 3:
		levelToLoad = "res://levels/IntroScene.tscn"
	elif Globals.currentStage <= 6:
		levelToLoad = "res://levels/Level2_1.tscn"
	elif Globals.currentStage <= 9:
		levelToLoad = "res://levels/Level3_1.tscn"
	elif Globals.currentStage <= 12:
		levelToLoad = "res://levels/Level4_1.tscn"
	elif Globals.currentStage <= 15:
		levelToLoad = "res://levels/Level5_1.tscn"
	else:
		levelToLoad = "res://levels/Level6_1.tscn"
	
	Globals.clearCaches()
	Globals.startLevel = levelToLoad
	Globals.changeScene("res://GameContainer.tscn")
		
func toggleSelection():
	audioPlayer.stream = SELECT_SOUND
	audioPlayer.play()
	selectors[selectedIndex].modulate.a = 0
	selectedIndex = (selectedIndex + 1) % len(selectors)
	selectors[selectedIndex].modulate.a = 1
