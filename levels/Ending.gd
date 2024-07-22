extends Node2D

onready var shakeTimer: = $ShakeTimer
onready var castle: = $Background/CastleContainer/Castle
onready var dust: = $Background/Dust
onready var animationPlayer: = $AnimationPlayer
onready var creditsLabel: = $Credits

var shaking = false
onready var credits: = parseCredits() 

func _ready():
	Stats.screenView("Ending")
	var credits = parseCredits()
	MusicPlayer.playMusic("res://music/16 Voyager.mp3", false)
	startCollapse()
	
func startCollapse():
	dust.restart()
	yield(get_tree().create_timer(1.0), "timeout")
	shake()
	yield(get_tree().create_timer(1.3), "timeout")
	animationPlayer.play("Collapse")
	yield(animationPlayer, "animation_finished")
	shaking = false
	dust.emitting = false
	doCredits()
	
func doCredits():
	showText(credits)
	
func showText(lines: Array, index:int = 0):
	if index >= len(lines):
		if MusicPlayer.playing:
			yield(MusicPlayer, "finished")
		animationPlayer.play("ScreenFade")
		yield(animationPlayer, "animation_finished")
		# Go back to the title screen.
		Globals.changeScene("res://StandaloneStatsScreen.tscn")
		Globals.clearCaches()
		return
	creditsLabel.text = lines[index]
	creditsLabel.visible = true
	animationPlayer.play_backwards("TextFade")
	yield(animationPlayer, "animation_finished")
	yield(get_tree().create_timer(2), "timeout")
	animationPlayer.play("TextFade")
	yield(animationPlayer, "animation_finished")
	showText(lines, index + 1)
	
	
func parseCredits() -> Array:
	var groups = []
	var current = ""
	for line in CREDITS.split("\n"):
		if line == '\n':
			current += line
		else:
			line = line.strip_edges()
			if line == "-":
				groups.push_back(current)
				current = ""
			else:
				current += "\n" + line
	if len(current):
		groups.push_back(current)
	
	return groups

func shake():
	shaking = true
	var pos = castle.position
	
	while shaking:
		var x = round(rand_range(-1, 1))
		castle.position.x = pos.x + x
		
		shakeTimer.start()
		yield(shakeTimer, "timeout")
		
		
const CREDITS = """SCREENPLAY BY
VRAM STOKER

MUSIC BY
JAMES BANANA
-
PROGRAMMING
TONY CASALE
-
THE CAST:

DRACULA
CHRISTOPHER BEE
-
DEATH
BELO LUGOSI

FRANKENSTEIN
BORIS KARLOFFICE
-
MUMMY MAN
LOVE CHANEY JR.

MEDUSA
BARBER SHERRY
-
VAMPIRE BAT
MIX SCHRECKS

HUNCH BACK
LOVE CHANEY
-
FISH MAN
GREEN STRANGER

ARMOR
CAFEBAR READ
-
SKELETON
ANDRE MORAL

ZOMBIE
JONE CANDIES
-
AND THE HERO

SIMON BELMONDO
-
YOU PLAYED THE
GREATEST ROLE
IN THIS STORY
-
THANK YOU

FOR PLAYING
"""
