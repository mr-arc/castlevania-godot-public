extends Node

const GRAVITY = 600

const DAGGER_THROW = preload("res://sounds/09 - Dagger Throw.wav")
const WHIP_HIT = preload("res://sounds/20 - Whip Hit.wav")
const INEFFECTIVE_HIT = preload("res://sounds/16 - Ineffective Hit.wav")
const ITEM_PICKUP = preload("res://sounds/22 - Item Pickup.wav")
const WEAPON_PICKUP = preload("res://sounds/24 - Morning Star Pickup.wav")
const PORTAL_ENTRY = preload("res://sounds/25 - Enter Portal.wav")
const MONEY_PICKUP = preload("res://sounds/23 - Treasure Pickup.wav")
const HOLY_WATER_BREAK = preload("res://sounds/30 - Holy Water 1.wav")
const BLOCK_EXPLOSION = preload("res://sounds/21 - Broken Block.wav")
const REVEAL_SECRET = preload("res://sounds/34 - Secret Reveal.wav")
const SMALL_SPLASH = preload("res://sounds/14 - Small Splash.wav")
const INVISIBILITY_PICKUP = preload("res://sounds/27 - Invisibility On.wav")
const INVISIBILITY_OFF = preload("res://sounds/28 - Invisibility Off.wav")
const EXTRA_LIFE = preload("res://sounds/36 - 1up.wav")
const ROSARY_PICKUP = preload("res://sounds/35 - Rosary.wav")
const HARD_LANDING = preload("res://sounds/13 - Hard Landing.wav")

const BOSS_EXPLOSION = preload("res://bosses/BossExplosion.tscn")

var soundPlayer: SoundPlayer
var cheatsEnabled: bool = false
var currentStage: int = 1
export(String) var startLevel = "res://levels/IntroScene.tscn"

# Keeps track of whether we started stage 10. If we didn't, the first spawn
# is from above, so he falls into the scene.
var startedStage10 = false

var _game: Game
var _simon: Simon
var _hud: Hud
var isMobile: bool

func setFullscreen(full: bool) -> void:
	OS.window_fullscreen = full

func changeScene(scene: String) -> void:
	var shell = get_tree().root.find_node("MobileShell", false, false)
	if shell:
		for child in shell.get_node("Scene").get_children():
			child.queue_free()
		shell.get_node("Scene").add_child(load(scene).instance())
	else:
		get_tree().change_scene(scene)

func clearCaches():
	_simon = null
	_game = null
	_hud = null
	soundPlayer = null

func getSimon() -> Simon:
	if not _simon:
		_simon = get_tree().root.find_node("Simon", true, false)
	return _simon
	
func getGame() -> Game:
	if not _game:
		_game = get_tree().root.find_node("Game", true, false)
	return _game
	
func getHud() -> Hud:
	if not _hud:
		_hud =  get_tree().root.find_node("Hud", true, false)
	return _hud
	
func getViewportContainer() -> ViewportContainer:
	return get_tree().root.find_node("ViewportContainer", true, false) as ViewportContainer
	
# Returns a 2-element array where [0] is the min X coord and [1] is the max.
func getVisibleXRange() -> Array:
	var camera = getGame().getCamera()
	var camXMin = camera.position.x - camera.get_viewport_rect().size.x / 2
	var camXMax = camera.position.x + camera.get_viewport_rect().size.x / 2 

	return [camXMin, camXMax] 
	
# Returns a 2-element array where [0] is the min Y coord and [1] is the max.
func getVisibleYRange() -> Array:
	var camera = getGame().getCamera()
	var camYMin = camera.position.y - camera.get_viewport_rect().size.y / 2
	var camYMax = camera.position.y + camera.get_viewport_rect().size.y / 2
	return [camYMin, camYMax]
	
func loadLevel(level: String) -> void:
	(get_tree().root.find_node("Game", true, false) as Game).loadLevel(level)
	
func explodeNode(node: Node2D, location: Vector2, drop: String = "", muted: bool = false) -> void:
	Items.spawn(Items.EXPLODE, location)
	if not muted:
		playSound(WHIP_HIT, location)
	if not drop.empty():
		Items.call_deferred("spawn", drop, location)
	node.queue_free()
	
func bossExplode(node: Node2D, location: Vector2) -> void:
	var instance = BOSS_EXPLOSION.instance()
	Globals.getGame().add_child(instance)
	instance.global_position = location
	node.queue_free()
	
func playSound(sound: AudioStream, location:Vector2) -> void:
	if soundPlayer == null:
		soundPlayer = get_tree().root.find_node("SoundPlayer", true, false)
	soundPlayer.play(sound, location)
	
func isClickWithCheatsEnabled(event: InputEvent) -> bool:
	return Globals.cheatsEnabled and (
		(event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed) or
		(event is InputEventScreenTouch and event.pressed))
