extends Node2D

signal fatalDamage
signal dead
signal damaged(maxHealth, healthRemaining)

const FIREBALL = preload("res://enemies/Fireball.tscn")
const EXPLOSION = preload("res://items/Explode.tscn")

onready var simon: = Globals.getSimon()
onready var firePosition: = $FirePosition
onready var enemy: = $Enemy
onready var animationPlayer: = $AnimationPlayer
onready var animationTree: = $AnimationTree
onready var maxHealth = $Enemy.weakHits
onready var head: = $Head
onready var bodySprite: = $Body/Sprite

export var minDraculaX: float
export var maxDraculaX: float

var parent: WeakRef

func _ready():
	animationTree.active = true

func fire():
	var direction = firePosition.global_position.direction_to(simon.global_position + Vector2(0, -24))
	fireFireball(direction)
	fireFireball(direction.rotated(0.24))
	fireFireball(direction.rotated(-0.24))
	
func fireFireball(direction: Vector2):
	var fireball = FIREBALL.instance()
	fireball.damage = 4
	get_parent().add_child(fireball)
	fireball.direction = direction
	fireball.global_position = firePosition.global_position
	
func teleport():
	if not parent:
		parent = weakref(get_parent())
	# This can happen when dracula kills simon.
	if not parent.get_ref():
		return
		
	var timer = get_tree().create_timer(1.5)
	parent.get_ref().remove_child(self)
	yield(timer, "timeout")
	# This can happen when dracula kills simon.
	if not parent.get_ref() or not parent.get_ref().is_inside_tree():
		return
	var newX = round(rand_range(minDraculaX, maxDraculaX))
	scale.x = sign(newX - simon.global_position.x)
	position.x = parent.get_ref().to_local(Vector2(newX, 0)).x
	parent.get_ref().add_child(self)
	var stateMachine = animationTree["parameters/playback"] as AnimationNodeStateMachinePlayback
	stateMachine.travel("Materialize")
	
func _on_Body_hit(weapon):
	Globals.playSound(Globals.INEFFECTIVE_HIT, global_position)

func _on_Body_hit_simon():
	if not simon.invincible:
		simon.doDamage(enemy.damage)

func _on_Enemy_killed():
	emit_signal("fatalDamage")
	$Head/Hitbox.collision_mask = 0
	$Body.collision_mask = 0
	animationTree.active = false
	bodySprite.frame = 8
	
	yield(get_tree(), "idle_frame")
	var explode = EXPLOSION.instance()
	get_parent().add_child(explode)
	explode.global_position = head.global_position
	
	head.mode = RigidBody2D.MODE_RIGID
	head.collision_layer = 8
	head.collision_mask = 1
	head.apply_central_impulse(Vector2(scale.x * 50, -80))
	head.apply_torque_impulse(-scale.x * 1.0)
	animationPlayer.play("Dissolve")
	
	yield(animationPlayer, "animation_finished")
	Globals.explodeNode(head, head.global_position, "", true)
	
	emit_signal("dead")


func _on_Enemy_damaged(healthRemaining):
	emit_signal("damaged", maxHealth, healthRemaining)
