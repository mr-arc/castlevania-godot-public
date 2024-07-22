extends Node2D
tool

signal done

onready var audioStreamPlayer: = $AudioStreamPlayer
onready var animationPlayer: = $AnimationPlayer
onready var timer: = $Timer

export(int) var levelNum = 2 setget _setLevel

func _setLevel(value: int):
	levelNum = value
	for level in $Map.get_children():
		level.visible = level.name.ends_with(str(value))
		
func _ready():
	Stats.screenView("Map")
	_setLevel(levelNum)
	_playStep()
	
	if levelNum < 4:
		animationPlayer.play("LeftSide")
	else:
		animationPlayer.play("RightSide")
	
	yield(animationPlayer,"animation_finished")
	if levelNum == 4:
		runFallCutscene()
	else:
		emit_signal("done")
	
func _playStep():
	audioStreamPlayer.play()
	timer.wait_time = 0.27
	timer.start()
	yield(timer, "timeout")
	_playStep()
	
func runFallCutscene():
	remove_child(audioStreamPlayer)
	var cutscene = load("res://levels/FallCutscene.tscn").instance()
	add_child(cutscene)
	yield(cutscene.get_node("AnimationPlayer"), "animation_finished")
	emit_signal("done")
	
