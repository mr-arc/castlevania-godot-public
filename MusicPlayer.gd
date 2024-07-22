extends AudioStreamPlayer

const POISON_MIND = preload("res://music/08 Poison Mind.mp3")

var currentMusic: String	

func playBossMusic() -> void:
	stream = POISON_MIND
	stream.set_loop(true)
	play()

func playMusic(musicName: String, loop: bool = true) -> void:
	if musicName != currentMusic:
		currentMusic = musicName
		stream = load(musicName)
		stream.set_loop(loop)
		play()
	
func playDeath():
	playMusic("res://music/09 Player Miss.mp3", false)
	
func playLevelComplete():
	playMusic("res://music/11 Stage Clear.mp3", false)
	
