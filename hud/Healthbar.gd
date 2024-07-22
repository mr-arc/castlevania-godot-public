extends HBoxContainer
tool
class_name HealthBar

onready var timer: = $Timer

const PLAYER_BAR = preload("res://hud/PlayerBar.tres")
const ENEMY_BAR = preload("res://hud/EnemyBar.tres")
const BLANK_BAR = preload("res://hud/BlankBar.tres")

export(bool) var isPlayer = false
export(int) var health = Simon.MAX_HEALTH setget _setHealth
var nextDamageIndex = Simon.MAX_HEALTH - 1
var bars = []

func _setHealth(value):
	if value > health:
		nextDamageIndex = value - 1
		var i = 0
		for bar in bars:
			if value >= i:
				bar.texture = getBar()
			i += 1
	health = value

# Called when the node enters the scene tree for the first time.
func _ready():
	var bar = getBar()
	var barWidth = round(rect_size.y / 2)
	for i in range(Simon.MAX_HEALTH):
		var tex = TextureRect.new()
		tex.texture = bar
		tex.expand = true
		tex.size_flags_horizontal = TextureRect.SIZE_EXPAND_FILL
		tex.size_flags_vertical = TextureRect.SIZE_EXPAND_FILL
		tex.rect_min_size = Vector2(barWidth, rect_size.y)
		bars.append(tex)
		add_child(tex)
		
func getBar():
	return PLAYER_BAR if isPlayer else ENEMY_BAR
	
func resetDamage():
	health = Simon.MAX_HEALTH
	nextDamageIndex = health - 1
	for bar in bars:
		bar.texture = getBar()

func _on_Timer_timeout():
	if health - 1 == nextDamageIndex:
		return
	# Damage the next bar
	var bar = bars[nextDamageIndex] as TextureRect
	bar.texture = BLANK_BAR
	nextDamageIndex -= 1
		

func _on_Healthbar_gui_input(event: InputEvent):
	if isPlayer and Globals.isClickWithCheatsEnabled(event):
		var simon = Globals.getSimon()
		Globals.playSound(Globals.WEAPON_PICKUP, simon.global_position)
		simon.health = Simon.MAX_HEALTH
		
	
	
