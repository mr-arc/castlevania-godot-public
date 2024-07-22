extends Area2D

onready var timer: = $Timer

signal bossReady

func _on_BossArea_body_entered(body):
	if body is Simon:
		# Disconnect so we don't retrigger
		disconnect("body_entered", self, "_on_BossArea_body_entered")
		Globals.getGame().followSimon = false
		var tween = get_tree().create_tween()
		tween.tween_property(MusicPlayer, "volume_db", -20.0, 3).set_ease(Tween.EASE_IN)		
		tween.tween_property(MusicPlayer, "volume_db", -80.0, 1)
		tween.set_loops(1)
		yield(tween, "finished")
		tween.stop()
		tween.kill()
		yield(get_tree(), "idle_frame")
		
		MusicPlayer.playBossMusic()
		MusicPlayer.volume_db = 0
		emit_signal("bossReady")
		
