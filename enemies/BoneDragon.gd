extends Node2D

const FIREBALL = preload("res://enemies/Fireball.tscn")

onready var head: = $Parts/Head
onready var headSprite: = $Parts/Head/Sprite
onready var simon: = Globals.getSimon()
var direction = 1.0

enum State {
	ASLEEP,
	WAKING_UP,
	AWAKE,
	SHOOTING
}

var state = State.ASLEEP
var joints = []

func _ready():
	for child in $Parts.get_children():
		if child.name.begins_with("Neck"):
			child.get_node("Hitbox").connect("hit", self, "_on_NeckHitbox_hit", [child])
			var joint = child.get_node("Joint")
			joints.push_back(joint)
			child.remove_child(joint)
			var body = child as RigidBody2D
			if body:
				body.mode = RigidBody2D.MODE_STATIC
				
func _physics_process(delta):
	if state == State.ASLEEP:
		return
		
	if state == State.AWAKE:
		head.position.y += 60 * delta * direction
		if head.position.y > 64 or head.position.y < -32:
			direction *= -1
		
	if simon.global_position.x <= head.global_position.x:
		# Get angle to simon's face
		var dest = headSprite.global_position.angle_to_point(simon.global_position - Vector2(0, 24))
		headSprite.rotation = lerp_angle(headSprite.rotation, dest, delta * 5)
	else:
		headSprite.rotation = lerp_angle(headSprite.rotation, PI * 2, delta * 5)


func _on_Enemy_killed():
	for child in $Parts.get_children():
		if child.name.begins_with("Neck"):
			Globals.explodeNode(child, child.global_position, "random", true)
			
func wakeUp():
	state = State.WAKING_UP
	$AnimationPlayer.play("Awaken")
	yield($AnimationPlayer,"animation_finished")
	for child in $Parts.get_children():
		if child.name.begins_with("Neck"):
			var joint = joints.pop_front()
			child.add_child(joint)
			var body = child as RigidBody2D
			if body:
				body.mode = RigidBody2D.MODE_CHARACTER
	state = State.AWAKE

func _on_ActivateArea_body_entered(body):
	wakeUp()

func _on_DeactivateArea_body_entered(body):
	state = State.ASLEEP

func _on_NeckHitbox_hit(weapon, neckPiece: Node2D):
	Globals.playSound(Globals.INEFFECTIVE_HIT, neckPiece.global_position)

func _on_ShotTimer_timeout():
	if state == State.AWAKE:
		# Only shoot when simon is to the left
		if simon.global_position.x >= head.global_position.x:
			return
		
		state = State.SHOOTING
		headSprite.frame = 99
		var fireball = FIREBALL.instance()
		Globals.getGame().add_child(fireball)
		fireball.direction = head.global_position.direction_to(simon.global_position + Vector2(0, -16))
		fireball.global_position = head.global_position
	elif state == State.SHOOTING:
		headSprite.frame = 114
		state = State.AWAKE
	
	
