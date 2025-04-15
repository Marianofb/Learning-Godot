extends Node2D

## GAME ## 
var game : Game = null

@onready var tileMap = $"../TileMapLayer"
var aStarGrid : AStarGrid2D

func _ready() -> void:
	await owner._ready()
	game = owner as Game
	InitializeAStar()

func InitializeAStar():
	aStarGrid = AStarGrid2D.new()
	aStarGrid.region = tileMap.get_used_rect()
	aStarGrid.cell_size = Vector2(16,16)
	aStarGrid.update()
	
	ScanAllGridCellsForObstacles()

func GetPathToTarget(selfPosition, targetPosition) -> Array[Vector2i]:
	var path = aStarGrid.get_id_path(
		tileMap.local_to_map(selfPosition),
		tileMap.local_to_map(targetPosition)
	).slice(1)
	
	ShortenPath(path)
	
	return path

func ShortenPath(path : Array[Vector2i]):
	var pastPoint = Vector2.ZERO
	var i = 0
	while i < path.size() - 1:
		if(i > 0):
			var currentPoint = tileMap.map_to_local(path[i - 1]) - tileMap.map_to_local(path[i])
			if currentPoint == pastPoint:
				path.remove_at(i)
				path.remove_at(i-1)
			pastPoint = currentPoint
		i += 1

func ScanAllGridCellsForObstacles() -> void:
	var gridSize = aStarGrid.region.size
	var gridPosition = aStarGrid.region.position
	
	for x in range(gridPosition.x, gridPosition.x + gridSize.x):
		for y in range(gridPosition.y, gridPosition.y + gridSize.y):
			var cellPos = Vector2i(x, y)
			SetObjectPointSolid(cellPos)

# Función para obtener el nombre del objeto en una celda
func SetObjectPointSolid(cellPosition: Vector2i) -> void:
	var globalPos = tileMap.map_to_local(cellPosition)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = globalPos
	
	var result = space_state.intersect_point(query)
	if(ObjectFoundOnCellPosition(result)):
		var colliderMask : int = result[0]["collider"].get_collision_mask()
		if(colliderMask == game.GetLayerMaskObstacle()):
			aStarGrid.set_point_solid(cellPosition, true)
			SetAdjacentCellsWeight(cellPosition, 5)
		else:
			aStarGrid.set_point_solid(cellPosition, false)

func ObjectFoundOnCellPosition(result : Array) -> bool:
	return result.size() > 0
	
func SetAdjacentCellsWeight(cellPosition: Vector2i, weight: float = 5.0) -> void:
	# Definir las 8 celdas adyacentes (incluyendo diagonales)
	var directions = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-1, 1), 
		Vector2i(0, 1),   Vector2i(1, 1)
	]
	for dir in directions:
		var adjacentCell = cellPosition + dir

		if aStarGrid.region.has_point(adjacentCell) and not aStarGrid.is_point_solid(adjacentCell):
			var currentWeight = aStarGrid.get_point_weight_scale(adjacentCell)
			aStarGrid.set_point_weight_scale(adjacentCell, currentWeight + weight)
