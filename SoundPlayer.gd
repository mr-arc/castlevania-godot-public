extends Node2D
class_name SoundPlayer

# This is used to play sound effects by stuff that might not live long.

func play(sound: AudioStream, location: Vector2):
	for child in get_children():
		var player = child as AudioStreamPlayer2D	
		if not player.playing:
			player.stream = sound
			player.position = location
			player.play()
			return
			
