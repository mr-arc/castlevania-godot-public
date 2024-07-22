extends Node2D

func _ready():
	Stats.screenView("Intro Cutscene")
	MusicPlayer.playMusic("res://music/01 Prologue.mp3", false)

func _on_AnimationPlayer_animation_finished(anim_name):
	Globals.changeScene("res://GameContainer.tscn")
