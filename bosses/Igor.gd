extends KinematicBody2D

const FIREBALL = preload("res://enemies/Fireball.tscn")
const MIN_JUMP_POWER = 90
const MAX_JUMP_POWER = 280
const JUMP_INTERVAL = 45
const X_SPEED = 50

onready var animatedSprite: = $AnimatedSprite
onready var timer: = $Timer
onready var freezeTimer: = $FreezeTimer
onready var simon: = Globals.getSimon()

var velocity = Vector2.ZERO
var jumpPower = MIN_JUMP_POWER
var gravity = 280

var awake = false
var frozen = false
var stopped = false

func wakeUp():
	awake = true
	jump()

func jump():
	animatedSprite.play("Jumping")
	velocity = Vector2(X_SPEED * -sign(animatedSprite.scale.x), -jumpPower)
	jumpPower += JUMP_INTERVAL
	if jumpPower >= MAX_JUMP_POWER:
		jumpPower = MIN_JUMP_POWER
		
func freeze():
	Stats.kill("Igor", Globals.currentStage)
	frozen = true
	modulate.a = 0.25
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 2.0)
	tween.set_ease(Tween.EASE_OUT)
	yield(tween, "finished")
	if is_instance_valid(self):
		frozen = false
	
		
func fire():	
	var fireball = FIREBALL.instance()
	fireball.damage = 4
	Globals.getGame().levelScene.add_child(fireball)
	fireball.direction = global_position.direction_to(simon.global_position + Vector2(0, -16))
	fireball.global_position = global_position
	
func _physics_process(delta):		
	if frozen or stopped or not awake:
		return
		
	velocity.y += gravity * delta
	move_and_slide(velocity, Vector2.UP)
	if is_on_wall():
		animatedSprite.scale.x *= -1
		velocity.x *= -1 
	
	elif is_on_floor():
		stopped = true
		animatedSprite.play("Stopped")
		velocity.y = 0
		timer.start()
		yield(timer, "timeout")
		stopped = false
		jump()


func _on_ShotTimer_timeout():
	if awake and not frozen:
		fire()


func _on_Hitbox_hit_simon():
	if awake and not frozen and not simon.invincible:
		simon.doDamage(4)

func _on_Hitbox_hit(weapon):
	if awake and not frozen:
		freeze()
