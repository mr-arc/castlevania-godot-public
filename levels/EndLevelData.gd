extends Node
class_name EndLevelData

export(NodePath) var crystalLocation
export(int) var nextLevelNum = 1
export(String, FILE, "*.tscn") var nextLevel

func spawnCrystal():
	EndLevel.spawnCrystal(get_node(crystalLocation), nextLevelNum, nextLevel)
