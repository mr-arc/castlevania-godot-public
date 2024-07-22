extends CenterContainer

const LEVELS = [
	{
		"stage": "Stage 1A - Castle Approach",
		"scene": "res://levels/IntroScene.tscn",
	},
	{
		"stage": "Stage 1B - Outer Hall",
		"scene": "res://levels/Level1_1.tscn",
	},
	{
		"stage": "Stage 2 - Inner Chamber/Sewers",
		"scene": "res://levels/Level1_2.tscn",
	},
	{
		"boss": "Phantom Bat",
		"stage": "Stage 3 - Inner Hall",
		"scene": "res://levels/Level1_3.tscn",
	},
	{
		"stage": "Stage 4 - Tower Ascent 1",
		"scene": "res://levels/Level2_1.tscn",
	},
	{
		"stage": "Stage 5 - Tower Ascent 2",
		"scene": "res://levels/Level2_2.tscn",
	},
	{
		"boss": "Medusa",
		"stage": "Stage 6 - Medusa's Lair",
		"scene": "res://levels/Level2_3.tscn",
	},
	{
		"stage": "Stage 7 - Courtyard",
		"scene": "res://levels/Level3_1.tscn",
	},
	{
		"stage": "Stage 8 - Battlements",
		"scene": "res://levels/Level3_2.tscn",
	},
	{
		"boss": "Mummy Men",
		"stage": "Stage 9 - Bridge",
		"scene": "res://levels/Level3_3.tscn",
	},
	{
		"stage": "Stage 10 - Subterranian Lake",
		"scene": "res://levels/Level4_1.tscn",
	},
	{
		"stage": "Stage 11 - Killing Field",
		"scene": "res://levels/Level4_2.tscn",
	},
	{
		"boss": "Frankenstein & Igor",
		"stage": "Stage 12 - Castle Basement",
		"scene": "res://levels/Level4_3.tscn",
	},
	{
		"stage": "Stage 13 - Lower Crypt",
		"scene": "res://levels/Level5_1.tscn",
	},
	{
		"stage": "Stage 14 - Upper Crypt",
		"scene": "res://levels/Level5_2.tscn",
	},
	{
		"boss": "Grim Reaper",
		"stage": "Stage 15 - The Gallery",
		"scene": "res://levels/Level5_3.tscn",
	},
	{
		"stage": "Stage 16 - Crumbling Bridge",
		"scene": "res://levels/Level6_1.tscn",
	},
	{
		"stage": "Stage 17 - Clock Tower",
		"scene": "res://levels/Level6_2.tscn",
	},
	{
		"boss": "Dracula",
		"stage": "Stage 18 - The Count's Lair",
		"scene": "res://levels/Level6_3.tscn",
	},
]
const DING = preload("res://sounds/06 - Ding ding.wav")
const SELECT = preload("res://sounds/01 - Game Select.wav")

onready var levelParent: = $VBoxContainer/LevelMap/Levels
onready var audioPlayer: = $AudioStreamPlayer
onready var descriptionLabel: = $VBoxContainer/StageLabel/Description
onready var bossLabel: = $VBoxContainer/StageLabel/Boss
onready var stageLabel: = $VBoxContainer/StageLabel
onready var flashTimer: = $FlashTimer
onready var timer: = $Timer

var levels = []
var selectedIndex: int = 0
var loadingLevel = false

func _ready():
	Stats.screenView("LevelSelect")
	MusicPlayer.playMusic("res://music/02 Bloody Tears.mp3")
	for level in levelParent.get_children():
		levels.push_back(level)
		
	selectLevel(0, true)
		
func selectLevel(index: int, muted: bool = false):
	if not muted:
		audioPlayer.stream = DING
		audioPlayer.play()
	for level in levels:
		level.visible = false
	levels[index].visible = true
	descriptionLabel.text = LEVELS[index]["stage"]
	if LEVELS[index].has("boss"):
		bossLabel.text = "BOSS: " + LEVELS[index]["boss"]
	else:
		bossLabel.text = ""
	selectedIndex = index
	
func loadSelectedLevel():
	Stats.selectLevel(LEVELS[selectedIndex]["stage"])
	loadingLevel = true
	audioPlayer.stream = SELECT
	audioPlayer.play()
	timer.start()
	flashTimer.start()
	
func _process(delta):
	if loadingLevel:
		return
		
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_down"):
		selectLevel((selectedIndex - 1) % len(levels))
	elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_up"):
		selectLevel((selectedIndex + 1) % len(levels))
	elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_ENTER):
		loadSelectedLevel()
			
		
func _on_LevelMap_gui_input(event):
	if loadingLevel:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var position = event.global_position
		for i in range(len(levels)):
			var level = levels[i] as Polygon2D
			if Geometry.is_point_in_polygon(level.to_local(position), level.polygon):
				selectLevel(i)
				if event.doubleclick:
					loadSelectedLevel()
				return
			
func _on_Timer_timeout():
	Globals.startLevel = LEVELS[selectedIndex]["scene"]
	Globals.changeScene("res://GameContainer.tscn")


func _on_FlashTimer_timeout():
	stageLabel.modulate.a = abs(stageLabel.modulate.a - 1)
