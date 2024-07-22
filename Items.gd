extends Node

const MORNING_STAR = "morningStar"
const SMALL_HEART = "smallHeart"
const BIG_HEART = "bigHeart"
const RANDOM = "random"
const ROSARY = "rosary"
const DAGGER = "dagger"
const HOLY_WATER = "holywater"
const AXE = "axe"
const CROSS = "cross"
const CLOCK = "clock"
const DOUBLE_SHOT = "doubleshot"
const TRIPLE_SHOT = "tripleshot"
const PORK_CHOP = "porkchop"
const INVISIBILITY_POTION = "invisibilitypotion"
const MONEY_PATTERN = "(red|blue|yellow)\\$(\\d+)"
const DOUBLE_OR_TRIPLE = "doubleortriple"
const ENEMY = "enemy" # maybe, or maybe not spawns an enemy drop

# Not droppables, but these are the different whip levels.
const WHIP_1 = "whip1"
const WHIP_2 = "whip2"
const WHIP_3 = "whip3"

const EXPLODE = "Explode"

const explodeScene = preload("res://items/Explode.tscn")
const smallHeart = preload("res://items/SmallHeart.tscn")
const bigHeart = preload("res://items/BigHeart.tscn")
const morningStar = preload("res://items/MorningStar.tscn")
const moneyBag = preload("res://items/MoneyBag.tscn")
const weaponItem = preload("res://items/WeaponItem.tscn")
const blockExplosion = preload("res://levels/BlockExplosion.tscn")
const porkChop = preload("res://items/PorkChop.tscn")
const invisibilityPotion = preload("res://items/InvisibilityPotion.tscn")
const doubleShot = preload("res://items/DoubleShot.tscn")
const tripleShot = preload("res://items/TripleShot.tscn")
const rosary = preload("res://items/Rosary.tscn")

const axe = preload("res://items/Axe.tscn")
const dagger = preload("res://items/Dagger.tscn")
const holyWater = preload("res://items/HolyWater.tscn")
const cross = preload("res://items/Cross.tscn")
const clock = preload("res://items/Clock.tscn")

var moneyPattern = RegEx.new()

var spawnedDoubleShot = false
var spawnedTripleShot = false
var morningStarPresent = false

func gameNode() -> Game:
	return Globals.getGame()
	
func simon() -> Simon:
	return Globals.getSimon()

func _ready():
	moneyPattern.compile(MONEY_PATTERN)

func spawn(item:String, location:Vector2):
	match item:
		ENEMY:
			spawnRandomEnemyDrop(location)
		MORNING_STAR:
			_doSpawn(morningStar, location)
		SMALL_HEART:
			_doSpawn(smallHeart, location)
		BIG_HEART:
			_doSpawn(bigHeart, location)
		EXPLODE:
			_doSpawn(explodeScene, location)
		PORK_CHOP:
			_doSpawn(porkChop, location)
		INVISIBILITY_POTION:
			_doSpawn(invisibilityPotion, location)
		ROSARY:
			_doSpawn(rosary, location)
		DOUBLE_OR_TRIPLE:
			if simon().maxShots >= 3:
				_doSpawn(smallHeart, location)
			elif simon().maxShots == 2:
				_doSpawn(tripleShot, location)
			else:
				_doSpawn(doubleShot, location)
		RANDOM:
			_spawnRandom(location)
		
		# Weapon spawns
		AXE:
			_doSpawn(axe, location)
		DAGGER:
			_doSpawn(dagger, location)
		HOLY_WATER:
			_doSpawn(holyWater, location)
		CROSS:
			_doSpawn(cross, location)
		CLOCK:
			_doSpawn(clock, location)
			
		var special:
			_spawnSpecial(special, location)
			
func _spawnSpecial(special: String, location: Vector2):
	var moneyMatch = moneyPattern.search(special)
	if moneyMatch:
		var color = moneyMatch.get_string(1)
		var points = int(moneyMatch.get_string(2))
		var type = 0 if color == "red" else 1 if color == "blue" else 2
		var instance = _doSpawn(moneyBag, location) as MoneyBag
		instance.points = points
		instance.type = type
		return
	print("TODO: Spawn a %s" % special)
	
func _morningStarGone():
	morningStarPresent = false
		
func _spawnRandom(location: Vector2, includeSpecials: bool = false):
	# Spawn a morning star if you have at least 4 hearts and are at level 1, or 8 hearts at level 1.
	# Only spawn a morning star if one is not already present.
	if not morningStarPresent and (
			simon().whipLevel == 1 and simon().hearts >= 4) or (simon().whipLevel == 2 and simon().hearts >= 8):
		morningStarPresent = true
		var instance = _doSpawn(morningStar, location)
		instance.connect("tree_exited", self, "_morningStarGone")
		return
		
	# TODO: If simon has a secondary weapon, check to see if a double or triple shot should
	# be dropped.
	if simon().maxShots == 1 and not spawnedDoubleShot and simon().shotCount >= 10:
		_doSpawn(doubleShot, location)
		spawnedDoubleShot = true
		return
	if simon().maxShots == 2 and not spawnedTripleShot and simon().shotCount >= 20:
		_doSpawn(tripleShot, location)
		spawnedTripleShot = true
		return
		
	# Pick a random number from 1 to 100 to see what spawns.
	var roll = randi() % 100 + 1
	
	# TODO: Checkout RNGTools add on for loot drops
	
	# 1% chance of dropping a rosary
	if roll <= 1:
		spawn(ROSARY, location)
		return
	# 10% chance of dropping a blue 400 money or a special (if we ask for it)
	if roll <= 1 + 10:
		if includeSpecials:
			var item = _getSpecialSpawn()
			if item != simon().weapon:
				spawn(item, location)
				return
			else:
				spawn("blue$400", location)
		
	# 25% chance of dropping red 100 pt. money
	if roll <= 1 + 10 + 25:
		spawn("red$100", location)
	# Otherwise drop a small heart
	else:
		spawn(SMALL_HEART, location)
		
func _getSpecialSpawn():
	# Based on stag drop tables
	var stage = Globals.getHud().stage
	var candidates = []
	if stage <= 3:
		candidates = [HOLY_WATER, CLOCK]
	elif stage <= 6:
		candidates = [HOLY_WATER, CROSS]
	elif stage <= 9:
		candidates = [ROSARY, INVISIBILITY_POTION, ROSARY]
	elif stage <= 12:
		candidates = [AXE, INVISIBILITY_POTION, ROSARY]
	elif stage <= 15:
		candidates = [DAGGER, INVISIBILITY_POTION, CLOCK]
	else:
		candidates = [CLOCK, ROSARY, CROSS]
		
	var index = randi() % len(candidates)
	return candidates[index]
			
func _doSpawn(scene, location: Vector2):
	var instance = scene.instance()
	instance.position = location
	gameNode().call_deferred("add_child", instance)
	return instance
	
func spawnRandomEnemyDrop(location: Vector2):	
	# Enemies drop stuff 25% of the time
	var roll = randi() % 100 +1
	if roll <= 25:
		_spawnRandom(location, true)
		
func spawnBlockExplosion(location: Vector2):
	_doSpawn(blockExplosion, location)

func getWeaponDamage(weapon: String) -> int:
	match weapon:
		AXE, WHIP_2, WHIP_3:
			return 2
	return 1
