extends Node2D

## GAME ## 
var game : Game = null

@onready var tileMap = $"../TileMapLayer"
var aStarGrid : AStarGrid2D

func _ready() -> void:
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

#Shorten Path in cases where we can find am L 
#where the origin can reach the end in a diagonal movement
#and there is no obstacle in the way
func ShortenPath(path : Array[Vector2i]):
	var i = 0
	while i < path.size() - 1:
		if(i > 1):
			var currentPoint : Vector2i = tileMap.map_to_local(path[i - 2])
			var secondPoint : Vector2i = tileMap.map_to_local(path[i - 1])
			var thirdPoint : Vector2i = tileMap.map_to_local(path[i])
			#It represents the total sum of the distance from 0 -> 2
			var distanceThirdPoint : float = (thirdPoint - currentPoint).length()
			#It represents the total sum of the distance from 0 -> 1 + 1 -> 2
			var distanceSecondPoint : float =   (secondPoint - currentPoint).length() + (thirdPoint - secondPoint).length()
			print('distanceThirdPoint: ' , distanceThirdPoint)
			print('distanceSecondPoint: ' , distanceSecondPoint)
			if !RaycastHitsObstacle(currentPoint, thirdPoint) && distanceThirdPoint < distanceSecondPoint:
				path.remove_at(i-1)
		i += 1

func RaycastHitsObstacle(origin:Vector2i, destiny:Vector2i) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, destiny)
	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		if collider.get_collision_mask() == game.GetLayerMaskObstacle() : 
			return true
	
	return false

func ScanAllGridCellsForObstacles() -> void:
	var gridSize = aStarGrid.region.size
	var gridPosition = aStarGrid.region.position
	
	for x in range(gridPosition.x, gridPosition.x + gridSize.x):
		for y in range(gridPosition.y, gridPosition.y + gridSize.y):
			var cellPos = Vector2i(x, y)
			SetObjectPointSolid(cellPos)

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
