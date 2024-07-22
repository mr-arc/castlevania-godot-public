extends KinematicBody2D
class_name Simon

const MAX_HEALTH = 16
const WEAPON_Y_OFFSET = -24

const weaponDagger: = preload("res://items/WeaponDagger.tscn")
const weaponHolyWater: = preload("res://items/WeaponHolyWater.tscn")
const weaponAxe: = preload("res://items/WeaponAxe.tscn")
const weaponCross: = preload("res://items/WeaponCross.tscn")
const invisibleShader: = preload("res://shaders/InvisibilitySimon.tres")

signal healthChanged(value)
signal damage(value)
signal respawn
signal weaponPickup(weapon)

onready var sprite: = $Sprites/Sprite
onready var animationPlayer: = $AnimationPlayer
onready var collisionShape: = $CollisionShape2D
onready var whipSprite: = $Sprites/WhipSprite
onready var whipSound: = $WhipSound
onready var damagedSound: = $DamagedSound
onready var sprites: = $Sprites
onready var knockbackTimer: = $KnockbackTimer
onready var respawnTimer: = $RespawnTimer
onready var upStepPosition: = $Sprites/UpStepPosition
onready var downStepPosition: = $Sprites/DownStepPosition
onready var upStepCheck: = $Sprites/UpStepCheck
onready var downStepCheck: = $Sprites/DownStepCheck
onready var fallDuckTimer: = $FallDuckTimer
onready var game = Globals.getGame()
onready var weaponNode = game.find_node("Weapons", true, false)

onready var invisibilityMaterial 

enum State {
	WALKING,
	DUCKING,
	FALLING,
	ON_STAIRS,
	KNOCKBACK,
	DYING,
	DEATH,
	STARTING_UP_STEPS,
	STARTING_DOWN_STEPS,
	UP_STEPS,
	DOWN_STEPS,
	CUTSCENE,
}

enum {
	LEFT, RIGHT
}

export(int) var walkingSpeed = 64
export(int) var jumpSpeed = 220
export(Vector2) var knockbackSpeed = Vector2(60, 140)
export(int) var whipLevel = 1
export(int) var score = 0 setget _setScore, _getScore
export(int) var hearts = 5 # start with 5 hearts
export(int) var lives = 3
export(bool) var invincible = false setget _setInvincible, _getInvincible
export(int) var maxShots = 1
var weapon

var state  = State.WALKING
var velocity = Vector2.ZERO
var isWhipping = false
var isDucking = false
var isJumping = false
var initialWhipOffset: Vector2
var walkingTo = null
var walkingToCallback: FuncRef = null
var health: int = MAX_HEALTH setget _setHealth, _getHealth
var currentStairs: StairData = null
var currentStairAnimation: String = ""
var doneWhippingCallback: FuncRef = null
# Keep track of how many shots so we know to spawn a double or triple shot
var shotCount = 0
var jumpY: float = 40000
const JUMPY_OFFSET = 48

var nextExtraLifeThreshold = 30000

func _setInvincible(value: bool):
	invincible = value
func _getInvincible():
	return invincible
	
func _setScore(value: int):
	score = value
	if score >= nextExtraLifeThreshold:
		grantExtraLife()
		nextExtraLifeThreshold += 30000
	
func _getScore() -> int:
	return score

func _setHealth(value: int):
	if value < 0:
		value = 0
	elif value > MAX_HEALTH:
		value = MAX_HEALTH
	health = value
	emit_signal("healthChanged", health)
func _getHealth() -> int:
	return health
	
func grantExtraLife():
	Globals.playSound(Globals.EXTRA_LIFE, global_position)
	lives += 1
	
func _ready():
	# Remember the initial offset of the whip sprite
	whipSprite.visible = false
	initialWhipOffset = whipSprite.position
	invisibilityMaterial = ShaderMaterial.new()
	invisibilityMaterial.shader = invisibleShader
	
func _physics_process(delta):
	match state:
		State.WALKING:
			doWalking(delta)
		State.FALLING:
			doFalling(delta)
		State.KNOCKBACK:
			doKnockback(delta)
		State.DYING:
			doDying(delta)
		State.STARTING_UP_STEPS:
			doStartingUpSteps(delta)
		State.STARTING_DOWN_STEPS:
			doStartingDownSteps(delta)
		State.UP_STEPS:
			doSteps(delta, -1)
		State.DOWN_STEPS:
			doSteps(delta, 1)
		State.CUTSCENE:
			doCutscene(delta)
			
func isGoingDown() -> bool:
	return state == State.DOWN_STEPS
func isGoingUp() -> bool:
	return state == State.UP_STEPS
	
func setIdle():
	animationPlayer.play("Idle")
			
func setWeapon(weapon: String) -> void:
	if self.weapon == weapon:
		return
	self.weapon = weapon
	maxShots = 1
	shotCount = 0
	Items.spawnedDoubleShot = false
	Items.spawnedTripleShot = false
	# Update the hud
	emit_signal("weaponPickup", weapon)
			
func startCutscene(animationName: String = ""):
	state = State.CUTSCENE
	invincible = true
	if animationName != "":
		animationPlayer.play(animationName)
	
func endCutscene():
	state = State.WALKING
	walkingTo = null
	walkingToCallback = null
	animationPlayer.current_animation = "Idle"
	invincible = false
	reset_physics_interpolation()
	
func walkTo(location: int, callback: FuncRef):
	walkingTo = location
	walkingToCallback = callback
	animationPlayer.current_animation = "Walk"
	
func doCutscene(delta):
	if walkingTo == null:
		return
		
	var speed: float
	if position.x < walkingTo:
		faceRight()
		speed = 1.0
	else:
		faceLeft()
		speed = -1.0
	velocity = Vector2(speed * walkingSpeed, 0)
	move_and_slide(velocity, Vector2.UP)
	
	# check to see if we've reached the position
	if (position.x == walkingTo
		or (speed < 0 and position.x <= walkingTo)
		or (speed > 0 and position.x >= walkingTo)):
		walkingTo = null
		if walkingToCallback:
			walkingToCallback.call_func()
			
const DOWN_FRAME = 3
const UP_FRAME = 4
const STAND_FRAME = 1
func doStartingUpSteps(delta):	
	# walk to step position
	var stepStart = StairFuncs.getUpStartPosition(currentStairs)
	var direction = Vector2(stepStart.x - global_position.x, 0).normalized()
	animationPlayer.current_animation = "Walk"
	position = position + direction * Vector2(30, 0) * delta
	if direction.x <= 0:
		faceLeft()
		if global_position.x <= stepStart.x:
			state = State.UP_STEPS
			animationPlayer.current_animation = "UpSteps"
			currentStairAnimation = "UpSteps"
	else:
		faceRight()
		if global_position.x >= stepStart.x:
			state = State.UP_STEPS
			animationPlayer.current_animation = "UpSteps"
			currentStairAnimation = "UpSteps"
			
func doStartingDownSteps(delta):
	# walk to step position
	var stepStart = StairFuncs.getDownStartPosition(currentStairs)
	var direction = Vector2(stepStart.x - global_position.x, 0).normalized()
	animationPlayer.current_animation = "Walk"
	position = position + direction * Vector2(30, 0) * delta
	if direction.x <= 0:
		faceLeft()
		if global_position.x <= stepStart.x:
			state = State.DOWN_STEPS
			animationPlayer.current_animation = "DownSteps"
			currentStairAnimation = "DownSteps"
	else:
		faceRight()
		if global_position.x >= stepStart.x:
			state = State.DOWN_STEPS
			animationPlayer.current_animation = "DownSteps"
			currentStairAnimation = "DownSteps"
			
func _onDoneWhippingOnSteps():
	animationPlayer.current_animation = currentStairAnimation
	animationPlayer.advance(0.1)
	animationPlayer.stop()
	
func doSteps(delta, yDirection: float):
	if isWhipping:
		return
	
	if _maybeDoAttack(funcref(animationPlayer, "play"), funcref(self, "_onDoneWhippingOnSteps")):
		return	
		
	var xDirection
	var upAction
	var downAction
	if currentStairs.stairType == StairType.STAIRS_LEFT:
		xDirection = -1 if yDirection == -1 else 1
		upAction = "ui_left"
		downAction = "ui_right"
	else:
		xDirection = 1 if yDirection == -1 else -1
		upAction = "ui_right"
		downAction = "ui_left"
	if xDirection < 0:
		faceLeft()
	else:
		faceRight()
	
	if yDirection == -1:
		if Input.is_action_pressed("ui_up") or Input.is_action_pressed(upAction):
			position = position + Vector2(30 * xDirection, 30 * yDirection) * delta
			if not animationPlayer.is_playing():
				animationPlayer.play()
				
			# if we're at the top of the final stair, get off
			var onStair = game.getStairType(global_position)
			if onStair == StairType.NO_STAIRS:
				onStair = game.getStairType(upStepPosition.global_position)
				if onStair == StairType.NO_STAIRS:
					state = State.WALKING
			
		elif Input.is_action_pressed("ui_down") or Input.is_action_pressed(downAction):
			state = State.DOWN_STEPS
			animationPlayer.current_animation = "DownSteps"
			currentStairAnimation = "DownSteps"
			animationPlayer.play()
		else:
			animationPlayer.stop()
	else:
		if Input.is_action_pressed("ui_down") or Input.is_action_pressed(downAction):
			position = position + Vector2(30 * xDirection, 30 * yDirection) * delta
			if not animationPlayer.is_playing():
				animationPlayer.play()
			
			# if we're at the bottom of the final stair, get off
			var onStair = game.getStairType(downStepPosition.global_position)
			if onStair == StairType.NO_STAIRS:
				onStair = game.getStairType(global_position)
				if onStair == StairType.NO_STAIRS:
					state = State.WALKING
				
		elif Input.is_action_pressed("ui_up") or Input.is_action_pressed(upAction):
			state = State.UP_STEPS
			animationPlayer.current_animation = "UpSteps"
			currentStairAnimation = "UpSteps"
			animationPlayer.play()
		else:
			animationPlayer.stop()

# Handle attacking, returning true if an attack happened, and false if not
func _maybeDoAttack(onAttackFunc: FuncRef = null, onDoneFunc: FuncRef = null) -> bool:
	if Input.is_action_just_pressed("attack"):
		if Input.is_action_pressed("ui_up") and canFireSecondary():
			if onAttackFunc: onAttackFunc.call_func()
			doSecondaryWeapon(onDoneFunc)
			return true
		if onAttackFunc: onAttackFunc.call_func()
		doWhip(onDoneFunc)
		return true
	return false
	
func doWalking(delta):
	# If we're whipping, don't process any more input.
	if isWhipping:
		move_and_slide(velocity, Vector2.UP)
		return
		
	# See if we're on any up steps.
	whipSprite.visible = false
	var probe = upStepCheck.global_position
	var stairType = game.getStairType(probe)
	if stairType == StairType.NO_STAIRS:
		# Check one pixel above
		probe = global_position + Vector2(0, -1)
		stairType = game.getStairType(probe)
	if stairType != StairType.NO_STAIRS:
		if Input.is_action_just_pressed("ui_up"):
			state = State.STARTING_UP_STEPS
			currentStairs = game.getStairCase(probe)
			return
	# See if we're on any down steps.
	probe = downStepCheck.global_position
	stairType = game.getStairType(probe)
	if stairType == StairType.NO_STAIRS:
		# Check one pixel below
		probe = global_position + Vector2(0, 1)
		stairType = game.getStairType(probe)
	if stairType != StairType.NO_STAIRS:
		if Input.is_action_just_pressed("ui_down"):
			state = State.STARTING_DOWN_STEPS
			currentStairs = game.getStairCase(probe)
			return

	# While standing, a whip will stop forward motion
	if _maybeDoAttack():
		return
		
	var speed = 0.0;
	if Input.is_action_pressed("ui_down"):
		isDucking = true
	else:
		if isDucking and not fallDuckTimer.is_stopped():
			animationPlayer.play("Duck")
			return
		isDucking = false
		if Input.is_action_pressed("ui_left"):
			faceLeft()
			speed = -1.0
		elif Input.is_action_pressed("ui_right"):
			faceRight()
			speed = 1.0
		
	# Handle Jumping
	if is_on_floor():
		jumpY = global_position.y
		if isDucking and not fallDuckTimer.is_stopped():
			return
		if Input.is_action_just_pressed("jump"):
			isJumping = true
			state = State.FALLING
			animationPlayer.play("Jump")
			velocity = Vector2(speed * walkingSpeed, -jumpSpeed)
			move_and_slide(velocity, Vector2.UP)
			return
	else:
		# We're not on the floor, so we're now falling
		state = State.FALLING
		
		# TODO: Keep track of how far we fall so we know if we kneel at the end.
		return
		
	if speed == 0.0:
		if isDucking:
			animationPlayer.play("Duck")
		else:
			animationPlayer.play("Idle")
	else:
		animationPlayer.play("Walk")
	
	velocity = Vector2(speed * walkingSpeed, Globals.GRAVITY)
	move_and_slide(velocity, Vector2.UP)
	
func faceRight():
	sprites.scale.x = -1
	
func faceLeft():
	sprites.scale.x = 1

func isFacingRight():
	return sprites.scale.x == -1
	
func isFacingLeft():
	return sprites.scale.x == 1
	
# Returns a vector pointing in the same direction as simon.
func getFacing() -> Vector2:
	return Vector2(-sprites.scale.x, 0)
	
func startInvisibility():
	_setInvincible(true)
	material = invisibilityMaterial

func stopInvisibility():
	_setInvincible(false)
	material = null
	
func resetState():
	state = State.WALKING
	hearts = 5  # start with 5 hearts
	whipLevel = 1
	_setHealth(MAX_HEALTH)
	stopInvisibility()
	sprites.modulate.a = 1
	weapon = null
	maxShots = 1
	
func startTemporaryInvincibility():
	_setInvincible(true)
	sprites.modulate.a = 0.5
	knockbackTimer.start()
	
func doKnockback(delta):
	whipSprite.visible = false
	velocity += Vector2(0, Globals.GRAVITY * delta)
	move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		state = State.WALKING

func doDying(delta):
	# Same as knockback, but we don't get any alpha.
	whipSprite.visible = false
	velocity += Vector2(0, Globals.GRAVITY)
	velocity = move_and_slide(velocity, Vector2.UP)
	_setInvincible(true)
	if is_on_floor():
		kill()
		
func instaKill(reason: String = "Pit"):
	_setHealth(0)
	kill(reason)
		
func kill(reason: String = "Damage"):
	Stats.death(reason, score, lives, Globals.currentStage)
	_setInvincible(true)
	whipSprite.visible = false
	isWhipping = false
	$Sprites/WhipSprite/Hitbox/ShortHit.set_deferred("disabled", true)
	$Sprites/WhipSprite/Hitbox/MediumHit.set_deferred("disabled", true)
	$Sprites/WhipSprite/Hitbox/LongHit.set_deferred("disabled", true)
	state = State.DEATH
	MusicPlayer.playDeath()
	animationPlayer.current_animation = "Death"
	respawnTimer.start()
	
func isDead() -> bool:
	return state == State.DEATH
	
func doFalling(delta):
	if _maybeDoAttack():
		return
	var frameGravity = Globals.GRAVITY * delta
	if global_position.y > jumpY + JUMPY_OFFSET:
		frameGravity = Globals.GRAVITY * delta * 10
		velocity.x = 0
	velocity += Vector2(0, frameGravity)
	
	# we need to be able to jump over walls even if we jumped right next to them
	if is_on_wall() and isJumping:
		if isFacingLeft() && Input.is_action_pressed("ui_left"):
			velocity.x = -walkingSpeed
		elif isFacingRight() && Input.is_action_pressed("ui_right"):
			velocity.x = walkingSpeed

	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		if isWhipping:
			velocity.x = 0
		isJumping = false
		if global_position.y > jumpY + JUMPY_OFFSET:
			isDucking = true
			fallDuckTimer.start()
			Globals.playSound(Globals.HARD_LANDING, global_position)
			
		state = State.WALKING
		
func doWhip(callback: FuncRef = null):
	if is_on_floor():
		velocity.x = 0
	doneWhippingCallback = callback
	isWhipping = true
	$Sprites/WhipSprite/Hitbox.monitoring = true
	if isDucking:
		animationPlayer.current_animation = "DuckWhip%d" % whipLevel
	else:
		animationPlayer.current_animation = "Whip%d" % whipLevel
	whipSound.play()
	
func canFireSecondary() -> bool:
	var canFire = weapon != null and weaponNode.get_child_count() < maxShots
	if not canFire:
		return false
	if weapon == Items.CLOCK:
		return hearts >= 5
	return hearts > 0
	
func doSecondaryWeapon(callback: FuncRef = null):
	if weapon == Items.CLOCK:
		if hearts >= 5:
			if game.tryDoStopwatch():
				hearts -= 5
		# Don't forget to call the callback!
		if callback: callback.call_func()
		return
	
	isWhipping = true
	# Stop moving if we're on the ground
	if is_on_floor():
		velocity.x = 0
	animationPlayer.play("Throwing")
	yield(animationPlayer, "animation_finished")
	isWhipping = false
	
	var weaponScene: PackedScene
	
	match weapon:
		Items.DAGGER:
			weaponScene = weaponDagger
		Items.HOLY_WATER:
			weaponScene = weaponHolyWater
		Items.AXE:
			weaponScene = weaponAxe
		Items.CROSS:
			weaponScene = weaponCross
		var other:
			print("Unimplemented weapon: ", weapon)
	if weaponScene:
		hearts -= 1
		_fireWeapon(weaponScene)
	if callback: callback.call_func()
	
func _fireWeapon(weaponScene: PackedScene):
	var wpn = weaponScene.instance()
	wpn.connect("hit", self, "_weaponHitSomething", [wpn])
		
	wpn.global_position = global_position + Vector2(0, WEAPON_Y_OFFSET)
	if isFacingRight():
		wpn.faceRight()
	weaponNode.add_child(wpn)
	
func _weaponHitSomething(instance):
	shotCount += 1
	
func doneWhipping():
	$Sprites/WhipSprite/Hitbox/LongHit.disabled = true
	$Sprites/WhipSprite/Hitbox/MediumHit.disabled = true
	$Sprites/WhipSprite/Hitbox/ShortHit.disabled = true
	$Sprites/WhipSprite/Hitbox.monitoring = false
	isWhipping = false
	if doneWhippingCallback:
		doneWhippingCallback.call_func()
		doneWhippingCallback = null
		
func increaseWhipLevel():
	whipLevel = min(3, whipLevel + 1)
	
func doDamage(damage: int):
	if damage > health:
		damage = health
	_setHealth(health - damage)
	emit_signal("damage", damage)
	if isWhipping:
		call_deferred("doneWhipping")
	# Play hurt sound
	damagedSound.play()
	startTemporaryInvincibility()
	# Do not knockback on steps
	var shouldKnockback = state != State.DOWN_STEPS and state != State.UP_STEPS
	if shouldKnockback:
		animationPlayer.play("Knockback")
		velocity = Vector2(sprites.scale.x * knockbackSpeed.x, -knockbackSpeed.y)
		velocity = move_and_slide(velocity, Vector2.UP)
	if health == 0:
		state = State.DYING
	elif shouldKnockback:
		state = State.KNOCKBACK
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.begins_with("Whip") or anim_name.begins_with("DuckWhip"):
		doneWhipping()

# Called when the whip hits something.
func _on_Hitbox_area_entered(area):
	if area is Hitbox:
		var weapon = Items.WHIP_1
		if whipLevel == 2:
			weapon = Items.WHIP_2
		elif whipLevel == 3:
			weapon = Items.WHIP_3
		area.emitHit(weapon)

func _on_KnockbackTimer_timeout():
	# If we're in the middle of a cutscene DON'T make damagable
	if state != State.CUTSCENE:
		_setInvincible(false)
	sprites.modulate.a = 1
	
func _on_RespawnTimer_timeout():
	if lives == 0:
		Globals.changeScene("res://GameOverScreen.tscn")
		return
	lives -= 1
	emit_signal("respawn")
