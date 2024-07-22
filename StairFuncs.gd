extends Reference
class_name StairFuncs

# Returns the cell indices of the cell under the given global position.
static func getCellAt(tileMap: TileMap, globalLocation: Vector2) -> Vector2:
	if tileMap.is_inside_tree():
		return tileMap.world_to_map(tileMap.to_local(globalLocation))
	return Vector2.ZERO

static func getStairType(tileMap: TileMap, globalLocation: Vector2) -> int:
	if not tileMap:
		return StairType.NO_STAIRS
	var cellv = getCellAt(tileMap, globalLocation)
	return _stairTypeAtCell(tileMap, cellv)
	
static func getUpStartPosition(stairs: StairData) -> Vector2:
	var worldCoords = stairs.tileMap.to_global(stairs.tileMap.map_to_world(stairs.cellLocation))
	match stairs.stairType:
		StairType.STAIRS_LEFT:
			# lower right
			return worldCoords + Vector2(stairs.tileMap.cell_size)
		StairType.STAIRS_RIGHT:
			# lower left
			return worldCoords
	
	# Should be impossible
	return Vector2.ZERO
	
static func getDownStartPosition(stairs: StairData) -> Vector2:
	var worldCoords = stairs.tileMap.to_global(stairs.tileMap.map_to_world(stairs.cellLocation))
	match stairs.stairType:
		StairType.STAIRS_LEFT:
			# upper left
			return worldCoords + stairs.tileMap.cell_size * Vector2(0, -1)
		StairType.STAIRS_RIGHT:
			# upper right
			return worldCoords + stairs.tileMap.cell_size * Vector2(1, -1)
	
	# Should be impossible
	return Vector2.ZERO
	
static func getStairCase(tileMap: TileMap, globalLocation: Vector2) -> StairData:
	var cellv = getCellAt(tileMap, globalLocation)
	var stairType = _stairTypeAtCell(tileMap, cellv)
	if stairType == StairType.NO_STAIRS:
		return null

	var data = StairData.new()
	data.tileMap = tileMap
	data.cellLocation = cellv	
	data.stairType = stairType
	data.nextStepUp = _nextStep(tileMap, data, stairType, true)
	data.nextStepDown = _nextStep(tileMap, data, stairType, false)
	return data
	
static func _nextStep(tileMap: TileMap, currentStair: StairData, stairType: int, up: bool) -> StairData:
	var nextCoord: Vector2
	match stairType:
		StairType.STAIRS_LEFT:
			nextCoord = currentStair.cellLocation + Vector2(-1, -1 if up else 1)
			
		StairType.STAIRS_RIGHT:
			nextCoord = currentStair.cellLocation + Vector2(1, -1 if up else 1)
	
	var nextType = _stairTypeAtCell(tileMap, nextCoord)
	if nextType != stairType:
		return null
	var data = StairData.new()
	data.tileMap = tileMap
	data.cellLocation = nextCoord
	data.stairType = nextType
	data.nextStepUp = _nextStep(tileMap, data, stairType, up) if up else currentStair
	data.nextStepDown = _nextStep(tileMap, data, stairType, !up) if not up else currentStair
	return data

static func _stairTypeAtCell(tileMap: TileMap, cellLocation: Vector2) -> int:
	if tileMap.tile_set.has_meta("tile_meta"):
		var cell = tileMap.get_cellv(cellLocation)
		var meta = tileMap.tile_set.get_meta("tile_meta")
		if meta and meta.has(cell):
			var stairType = meta.get(cell)["StairType"]
			if stairType == "Left":
				return StairType.STAIRS_LEFT
			elif stairType == "Right":
				return StairType.STAIRS_RIGHT
	return StairType.NO_STAIRS
