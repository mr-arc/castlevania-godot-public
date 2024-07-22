extends Control
class_name Hud

onready var playerHealth: HealthBar = find_node("PlayerHealth", true, false)
onready var enemyHealth: HealthBar = find_node("EnemyHealth", true, false)

onready var scoreLabel: Label = find_node("Score")
onready var heartsLabel: Label = find_node("Hearts")
onready var livesLabel: Label = find_node("Lives")
onready var timeLabel: Label = find_node("Time")
onready var stageLabel: Label = find_node("Stage")
onready var weaponTexture: TextureRect = find_node("Weapon")
onready var simon: Simon = Globals.getSimon()
onready var game: Game = Globals.getGame()
onready var doubleShot: = find_node("DoubleShot")
onready var tripleShot: = find_node("TripleShot")

var score = 0
var hearts = 0
var lives = 0
var time = 0
var stage = 0

func _ready():
	simon.connect("healthChanged", self, "_on_simon_healthChanged")
	simon.connect("respawn", self, "_on_simon_respawn")
	simon.connect("weaponPickup", self, "_on_simon_weaponPickup")
	# TODO: handle enemy damage when the boss spawns
	
func _process(delta):
	setScore(simon.score)
	setHearts(simon.hearts)
	setLives(simon.lives)
	setTime(game.getRemainingTime())
	setShots(simon.maxShots)

func _on_simon_healthChanged(health: int):
	playerHealth.health = health

func _on_simon_respawn():
	playerHealth.resetDamage()
	enemyHealth.resetDamage()
	weaponTexture.texture = null
	
func _on_simon_weaponPickup(weapon):
	var tex
	match weapon:
		Items.DAGGER:
			tex = load("res://items/Dagger.tres")
		Items.HOLY_WATER:
			tex = load("res://items/HolyWater.tres")
		Items.AXE:
			tex = load("res://items/Axe.tres")
		Items.CROSS:
			tex = load("res://items/Cross.tres")
		Items.CLOCK:
			tex = load("res://items/Clock.tres")
		_:
			tex = null
	weaponTexture.texture = tex
	
func resetEnemyHealth():
	if enemyHealth:
		enemyHealth.health = 16
			
func setHearts(hearts: int):
	if self.hearts != hearts:
		self.hearts = hearts
		heartsLabel.text = _asTwoDigits(hearts)
		
func setStage(stage: int):
	if self.stage != stage:
		self.stage = stage
		stageLabel.text = _asTwoDigits(stage)
		
func setShots(maxShots: int):
	tripleShot.visible = maxShots >= 3
	doubleShot.visible = maxShots >= 2

func getHearts() -> int:
	return hearts
	
func setLives(lives: int):
	if self.lives != lives:
		self.lives = lives
		livesLabel.text = _asTwoDigits(lives)
		
func setTime(time: int):
	if self.time != time:
		self.time = time
		timeLabel.text = _asNDigits(time, 4)
		
func setScore(score: int):
	if self.score != score:
		self.score = score
		scoreLabel.text = _asNDigits(score, 6)
		
		
func _asTwoDigits(value: int) -> String:
	return str(value) if value >= 10 else "0%d" % value
	
func _asNDigits(value, digits: int) -> String:
	var strValue = str(value)
	var zeros = digits - len(strValue)
	return "{0}{1}".format(["0".repeat(zeros), value])


func _on_HeartTexture_gui_input(event):
	if Globals.isClickWithCheatsEnabled(event):
		Globals.playSound(Globals.ITEM_PICKUP, simon.global_position)
		simon.hearts += 1


func _on_PLabel_gui_input(event):
	if Globals.isClickWithCheatsEnabled(event):
		Globals.playSound(Globals.EXTRA_LIFE, simon.global_position)
		simon.lives += 1
