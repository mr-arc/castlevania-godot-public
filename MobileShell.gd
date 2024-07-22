extends MarginContainer

const DEAD_ZONE = 35.0
const MAX_DISTANCE = 200

onready var movement: = $"%Movement"
onready var center: = $"%Movement"/Center

var actions = {
	"ui_up": false,
	"ui_down": false,
	"ui_left": false,
	"ui_right": false,
}

func _ready():
	var tree: = get_tree()
	tree.set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, Vector2(1024, 448))

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		# If we're too far over (like clicking on a button), we ignore
		if event.position.x > MAX_DISTANCE:
			return

		if not movement.is_pressed():
			releaseAll()
			return

		var centerPosition = center.global_position
		var diff = event.position - centerPosition
		handleInput(diff)

func jslog(value):
	JavaScript.eval("console.log(' + " + str(value) + "')")
	
func handleInput(diff: Vector2):	
	if diff.x < -DEAD_ZONE:
		release("ui_right")
		press("ui_left")
	elif diff.x > DEAD_ZONE:
		release("ui_left")
		press("ui_right")
	else:
		release("ui_left")
		release("ui_right")
		
	if diff.y < -DEAD_ZONE:
		release("ui_down")
		press("ui_up")
	elif diff.y > DEAD_ZONE:
		release("ui_up")
		press("ui_down")
	else:
		release("ui_up")
		release("ui_down")
		
func press(action: String):
	if actions[action]:
		return
	actions[action] = true
	Input.action_press(action)
#	jslog("Press " + action)
	
func release(action: String):
	if not actions[action]:
		return
	actions[action] = false
	Input.action_release(action)
#	jslog("Release " + action)
	
func releaseAll():
	for key in actions.keys():
		release(key)


func _on_Any_Button_pressed():
	Input.action_press("ui_accept")
func _on_Any_Button_released():
	Input.action_release("ui_accept")
		
		
