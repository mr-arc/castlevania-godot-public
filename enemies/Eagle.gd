extends AnimatedSprite

export(int) var speed = 80
const MIN_DROP_OFFSET = 48
const MIN_DROP_TIME = 0.6
const MAX_DROP_TIME = 2.0

func faceLeft():
	scale.x = 1
	velocity = Vector2(speed * sign(-scale.x), 0)
	
func faceRight():
	scale.x = -1
	velocity = Vector2(speed * sign(-scale.x), 0)

onready var velocity = Vector2.ZERO
onready var simon: = Globals.getSimon()
onready var dropTimer: = $DropTimer
onready var killTimer: = $KillTimer

var onScreen = false
var dropChance = 0.2

func _ready():
	if velocity.length() == 0:
		velocity = Vector2(speed * sign(-scale.x), 0)
	dropTimer.wait_time = randomDropTime()
	dropTimer.start()
	yield(dropTimer, "timeout")
	maybeDrop()

func _physics_process(delta):
	position += velocity * delta
	
func maybeDrop():
	var num = rand_range(0, 1.0)
	if num < dropChance and abs(global_position.x - simon.global_position.x) >= MIN_DROP_OFFSET:
		dropFleaman()
	else:
		dropChance *= 2.0
	dropTimer.wait_time = 0.5
	dropTimer.start()
	velocity = Vector2.ZERO
	yield(dropTimer, "timeout")
	velocity = Vector2(speed * sign(-scale.x), 0)
	dropTimer.wait_time = randomDropTime()
	dropTimer.start()
	yield(dropTimer, "timeout")
	maybeDrop()
	
	
func randomDropTime():
	return rand_range(MIN_DROP_TIME, MAX_DROP_TIME)
	
func dropFleaman():
	var fleaMan = find_node("Fleaman", false)
	if fleaMan:
		fleaMan.show_behind_parent = false
		var location = fleaMan.global_position
		remove_child(fleaMan)
		get_parent().add_child(fleaMan)
		fleaMan.owner = get_parent()
		fleaMan.global_position = location
		fleaMan.drop()


func _on_Enemy_killed():
	var fleaMan = find_node("Fleaman", false)
	if fleaMan:
		Globals.explodeNode(fleaMan, fleaMan.global_position, "", true)


func _on_VisibilityNotifier2D_screen_exited():
	if onScreen and killTimer.is_inside_tree():
		killTimer.start()


func _on_VisibilityNotifier2D_screen_entered():
	onScreen = true
	killTimer.stop()
	
func _on_KillTimer_timeout():
	queue_free()
