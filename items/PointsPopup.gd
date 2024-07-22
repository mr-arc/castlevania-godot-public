extends CenterContainer
class_name PointsPopup

onready var pointsLabel: = $Points

export(int) var points  setget _setPoints, _getPoints

func _setPoints(value):
	points = value
	if pointsLabel:
		pointsLabel.text = str(points)

func _getPoints():
	return points
	
func _ready():
	pointsLabel.text = str(points)

func _on_Timer_timeout():
	queue_free()
