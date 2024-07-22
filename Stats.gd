extends Node

func _blankStats() -> Dictionary: 
	return {
		"Kills": {},
		"Deaths": {},
		"Score": 0,
		"Max Stage Reached": 0,
		"Max Stage Completed": 0,
	}

var localStats: Dictionary = _blankStats()
onready var js = OS.has_feature("JavaScript")

func screenView(screen: String) -> void:
	_logEvent("screen_view", {"firebase_screen": screen})
	
func selectLevel(stage) -> void:
	_logEvent("select_content", {
		"content_type": "level", 
		"item_id": str(stage),
	})

func levelStart(stage) -> void:
	localStats["Max Stage Reached"] = stage
	_logEvent("level_start", {
		"level_name": "Stage %s" % str(stage),
		"cheats": Globals.cheatsEnabled,
	})
	
func levelEnd(stage) -> void:
	localStats["Max Stage Completed"] = stage
	_logEvent("level_end", {"level_name": "Stage %s" % str(stage)})
	
func levelCompleted(stage, score: int, hearts: int, hp: int, lives: int, timeLeft: int) -> void:
	_logEvent("level_complete", {
		"score": score,
		"hearts": hearts,
		"hp": hp,
		"lives": lives,
		"time_left": timeLeft
	})
	
func death(reason: String, score: int, livesLeft: int,  stage) -> void:
	if not localStats["Deaths"].has(reason):
		localStats["Deaths"][reason] = 0
	localStats["Deaths"][reason] += 1
	localStats["Score"] = score
	_logEvent("death", {
		"reason": reason,
		"score": score,
		"lives_left": livesLeft,
		"stage": stage,
	})
	
func kill(enemy: String, stage) -> void:
	if not localStats["Kills"].has(enemy):
		localStats["Kills"][enemy] = 0
	localStats["Kills"][enemy] += 1
	_logEvent("kill", {
		"enemy": enemy,
		"stage": stage,
	})
	
func reachedBoss(bossName: String, stage) -> void:
	_logEvent("reached_boss", {
		"boss": bossName, 
		"stage": stage,
	})

func _logEvent(event:String, props: Dictionary) -> void:
	if not js:
		return
	
	JavaScript.eval("logEvent('%s', %s)" % [event, JSON.print(props)])

func resetLocalStats() -> void:
	localStats = _blankStats()
