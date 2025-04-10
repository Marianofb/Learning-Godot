class_name EnemyMovementWithTracker extends CharacterBody2D

# AStart
@export_category("AStar")
@onready var tileMap = $"../../TileMapLayer"
@onready var pathManager = $"../../PathManager"
@export var distanceThreshold : float = 30
var currentPath : Array[Vector2i]
var nextPathPosition : Vector2 = Vector2(0,0)
var distanceToNextPathPosition : float
var targetPosition : Vector2 = Vector2(0,0)

@export_category("Components")
var enemy: Enemy

func _ready() -> void:
	enemy = get_parent() as Enemy
	assert(enemy != null, "El nodo padre no es de tipo Player. Verifica la jerarquía de nodos.")
	enemy.InstantiateTracker()

func _process(delta: float) -> void:
	RequestPathToTarget(enemy.GetTrackerGlobalPosition(), 
						enemy.GetTargetGlobalPosition())
	
func _physics_process(delta: float) -> void:
	TrackerFollowPath(enemy.GetTrackerSpeed() , enemy.GetTrackerCharactearBody2D(), enemy.GetTrackerGlobalPosition())
	FollowTracker(enemy.GetSelfSpeed(), enemy.GetSelfCharactearBody2D(), enemy.GetSelfGlobalPosition(),
				enemy.GetSelfCurrentDirection(), enemy.GetTrackerGlobalPosition())
				
	queue_redraw()

func _draw() -> void:
	for pathPoint in currentPath:
		var pathPosition = tileMap.map_to_local(pathPoint)
		var square_size = 16 
		if pathPosition == targetPosition:
			draw_rect(Rect2(pathPosition - global_position - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.BLUE)
		elif pathPosition == nextPathPosition:
			draw_rect(Rect2(pathPosition - global_position - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.GREEN)
		else:	
			draw_rect(Rect2(pathPosition - global_position - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.RED)

func RequestPathToTarget(selfPostion, targetPostion):	
	if currentPath.is_empty():
		currentPath = pathManager.GetPathToTarget(selfPostion, targetPostion)
			
func TrackerFollowPath(trackerSpeed:float, 
					trackerCharacterBody2D:CharacterBody2D, trackerPosition:Vector2):
	if !currentPath.is_empty():
		targetPosition = tileMap.map_to_local(currentPath.back())
		nextPathPosition = tileMap.map_to_local(currentPath.front())
		distanceToNextPathPosition =  trackerPosition.distance_to(nextPathPosition)
		if distanceToNextPathPosition < distanceThreshold:
			currentPath.remove_at(0)
			
		var trackerDirection = nextPathPosition - trackerPosition
		trackerCharacterBody2D.velocity = trackerDirection.normalized()   * trackerSpeed
		trackerCharacterBody2D.move_and_slide()

func FollowTracker(selfSpeed:float, selfCharacterBody2D:CharacterBody2D, selfPosition:Vector2, 
				selfCurrentDirection:Vector2, trackerPostion:Vector2):
						
	var currentDirection = trackerPostion - selfPosition
	enemy.SetSelfCurrentDirection(currentDirection)
	
	selfCharacterBody2D.velocity = currentDirection.normalized()  * selfSpeed
	selfCharacterBody2D.move_and_slide()
