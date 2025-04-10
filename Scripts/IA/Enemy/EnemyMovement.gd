class_name EnemyMovement extends CharacterBody2D

# AStart
@export_category("AStar Components")
@onready var tileMap = $"../../TileMapLayer"
@onready var pathManager = $"../../PathManager"

@export_category("Pathing Variables")
@export var thresholdDistanceToNextNode : float = 20
@export var thresholdDistanceToOnArrival : float = 125
@export var thresholdDistanceFeelingSafe : float = 300
@export var distanceToDestination : float 
var distanceToNextPathPosition : float
var currentPath : Array[Vector2i]
var ahead : Vector2 
var ahead2 : Vector2
var avoidanceForce : Vector2
var feelingSafePosition : Vector2 = Vector2.ZERO
var feelingSafePositionDirection : Vector2 = Vector2.ZERO
var nextPointPosition : Vector2 = Vector2.ZERO
var lastTargetPosition : Vector2 = Vector2.ZERO

@export_category("Components")
var enemy: Enemy
@onready var selfCollisionShape2D : CollisionShape2D = get_node("CollisionShape2D")

func _ready() -> void:
	enemy = get_parent()
	await enemy._ready()
	RequestPathToTarget(enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition())

func _process(delta: float) -> void:
	RequestPathToTarget(enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition())
	GetAvoidanceForce(enemy.GetSelfGlobalPosition(), enemy.GetSelfCharactearBody2D(), enemy.GetAvoidanceRadius(), enemy.GetSelfSpeed())
	
func _physics_process(delta: float) -> void:
	#Seek(enemy.GetSelfSpeed(),enemy.GetDrag(), enemy.GetSelfCharactearBody2D(), enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition())
	FollowPath(enemy.GetSelfSpeed(),enemy.GetDrag(), enemy.GetSelfCharactearBody2D(), enemy.GetSelfGlobalPosition())
	#GoToFutureTargetPosition(enemy.GetSelfSpeed(), enemy.GetDrag(), enemy.GetTargetVelocity(),enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition(), enemy.GetSelfCharactearBody2D())
	#Flee(enemy.GetSelfSpeed(),enemy.GetDrag(), enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition(), enemy.GetSelfCharactearBody2D())
	#EvadeThreat(enemy.GetSelfSpeed(), enemy.GetDrag(), enemy.GetTargetVelocity(),enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition(), enemy.GetSelfCharactearBody2D())		
	
	queue_redraw()	

func _draw() -> void:
	draw_line(Vector2.ZERO, ahead, Color.BLACK)
	draw_line(Vector2.ZERO, ahead2, Color.WEB_GREEN)
	for pathPoint in currentPath:
		var pointPosition = tileMap.map_to_local(pathPoint)
		var square_size = 16 
		if pointPosition == lastTargetPosition:
			draw_rect(Rect2(pointPosition - enemy.GetSelfGlobalPosition() - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.BLUE)
		elif pointPosition == nextPointPosition:
			draw_rect(Rect2(pointPosition - enemy.GetSelfGlobalPosition() - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.GREEN)
		else:	
			draw_rect(Rect2(pointPosition - enemy.GetSelfGlobalPosition() - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.RED)

func RequestPathToTarget(selfPostion, targetPostion):	
	if currentPath.is_empty():
		currentPath = pathManager.GetPathToTarget(selfPostion, targetPostion)

func GetCollision() -> bool:
	if get_slide_collision_count() > 0:
		return true
		
	return false

func GetAvoidanceForce(selfGlobalPosition:Vector2, selfCharacterBody2D:CharacterBody2D, avoidanceRadius:float, selfSpeed : float) -> Vector2:
	var dynamicLength : float = selfCharacterBody2D.velocity.length() / selfSpeed
	ahead = selfCharacterBody2D.velocity.normalized() * avoidanceRadius 
	ahead2 = selfCharacterBody2D.velocity.normalized() * (avoidanceRadius * 0.5)
	var closestCollider : Node2D = GetClosestCollider()
	
	if (closestCollider != null):
		avoidanceForce = (ahead - closestCollider.global_position) * enemy.GetMaxAvoidanceForce()
	else:
		avoidanceForce = Vector2.ZERO


	return avoidanceForce

func RaycastHitsObstacle(selfGlobalPosition:Vector2, ahead:Vector2) -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(selfGlobalPosition, selfGlobalPosition + ahead)
	query.exclude = [selfCollisionShape2D]
	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		if collider.get_collision_mask() == enemy.game.GetLayerMaskObstacle() : 
			return collider
	
	return null
		
func GetClosestCollider() -> Node2D:
	
	var closestCollider : Node2D = null
	var distanceCollider : float = INF
	var distanceToClosestCollider : float = INF
	
	var aheadHit : Node2D = RaycastHitsObstacle(global_position, ahead) 
	var aheadHit2 : Node2D = RaycastHitsObstacle(global_position, ahead2)
	#if aheadHit:		
	#	print("aheadHit: ", aheadHit.get_parent().name)
	#if aheadHit2:		
	#	print("aheadHit2: ", aheadHit2.get_parent().name)
		

	if (closestCollider == null ||  distanceCollider < distanceToClosestCollider):
		if aheadHit :
			closestCollider = aheadHit
		elif aheadHit2:
			closestCollider = aheadHit2
			
		distanceToClosestCollider = distanceCollider
		#print("HIT: ", closestCollider.name)
	
	#if(closestCollider)	:
		#print("RETURN: ", closestCollider.name)
		
	return closestCollider
	
	
## SEEK ## 	
func Seek(selfSpeed:float, selfDrag:float, selfCharacterBody2D:CharacterBody2D, selfGlobalPosition:Vector2, destinationGlobalPosition:Vector2, ) -> void:
	var currentChaseDirection = destinationGlobalPosition - selfGlobalPosition
	enemy.SetSelfCurrentDirection(currentChaseDirection)
	
	#Steering Behaviour
	var desiredVelocity : Vector2 = currentChaseDirection.normalized() * selfSpeed
	desiredVelocity += avoidanceForce
	
	#OnArrival
	distanceToDestination = selfGlobalPosition.distance_to(lastTargetPosition)
	if(distanceToDestination <= thresholdDistanceToOnArrival):
		desiredVelocity = currentChaseDirection.normalized() * selfSpeed * (distanceToDestination / thresholdDistanceToOnArrival)
	
	var steering : Vector2 = (desiredVelocity - selfCharacterBody2D.velocity) / selfDrag
	
	#Check that enemy.velocity is equal or less than speed
	selfCharacterBody2D.velocity += steering + avoidanceForce
	selfCharacterBody2D.velocity = selfCharacterBody2D.velocity.normalized() * clamp(selfCharacterBody2D.velocity.length(), 0, selfSpeed)
	
		
	selfCharacterBody2D.move_and_slide()

func FollowPath(selfSpeed:float, selfDrag:float, selfCharacterBody2D:CharacterBody2D, selfGlobalPosition:Vector2):
	if !currentPath.is_empty():
		lastTargetPosition = tileMap.map_to_local(currentPath.back())
		nextPointPosition = tileMap.map_to_local(currentPath.front())
		distanceToNextPathPosition =  selfGlobalPosition.distance_to(nextPointPosition)
		if distanceToNextPathPosition < thresholdDistanceToNextNode:
			currentPath.remove_at(0)
	
	Seek(selfSpeed, selfDrag, selfCharacterBody2D, selfGlobalPosition, nextPointPosition, )		

func GoToFutureTargetPosition(selfSpeed:float, selfDrag:float, targetVelocity:Vector2, selfGlobalPosition:Vector2, targetGlobalPosition:Vector2,
							selfCharacterBody2D:CharacterBody2D) -> void:
	var distanceToTarget : Vector2 = targetGlobalPosition - selfGlobalPosition
	var timeToReachTargetPosition : float = distanceToTarget.length() / selfSpeed
	var futureTargetPosition : Vector2 	= targetGlobalPosition + targetVelocity * timeToReachTargetPosition
	
	Seek(selfSpeed, selfDrag, selfCharacterBody2D, selfGlobalPosition, nextPointPosition, )

## FLEE ## 
func Flee(selfSpeed:float, selfDrag:float, selfGlobalPosition:Vector2, threatGlobalPosition:Vector2,
							selfCharacterBody2D:CharacterBody2D) -> void:
	#The direction is oriented to the opossite way of the threat
	var currentFleeDirection =  selfGlobalPosition - threatGlobalPosition
	var distanceToThreat : float = selfGlobalPosition.distance_to(threatGlobalPosition)
	SetFeelingSafePositionANDDirection(distanceToThreat, threatGlobalPosition, selfGlobalPosition, thresholdDistanceFeelingSafe, currentFleeDirection)
	enemy.SetSelfCurrentDirection(feelingSafePositionDirection)
	
	#Steering Behaviour
	var desiredVelocity : Vector2 = currentFleeDirection.normalized() * selfSpeed
	
	#Less or greater than considered safe zone distance or radius
	var distanceToFeelingSafePosition : float = selfGlobalPosition.distance_to(feelingSafePosition)
	if(distanceToThreat >= thresholdDistanceFeelingSafe): 
		desiredVelocity = feelingSafePositionDirection.normalized() * selfSpeed * (distanceToFeelingSafePosition / thresholdDistanceFeelingSafe)
			
	var steering : Vector2 = (desiredVelocity - selfCharacterBody2D.velocity) / selfDrag
	
	#Check that enemy.velocity is equal or less than speed
	selfCharacterBody2D.velocity += steering
	selfCharacterBody2D.velocity = selfCharacterBody2D.velocity.normalized() * clamp(selfCharacterBody2D.velocity.length(), 0, selfSpeed)
		
	selfCharacterBody2D.move_and_slide()

func SetFeelingSafePositionANDDirection(distanceToThreat:float, threatGlobalPosition:Vector2, selfGlobalPosition:Vector2, thresholdDistanceFeelingSafe:float, currentFleeDirection:Vector2 ) -> void:
	if(distanceToThreat <= thresholdDistanceFeelingSafe):
		var x:float = threatGlobalPosition.x + (thresholdDistanceFeelingSafe * currentFleeDirection.normalized().x)
		var y:float = threatGlobalPosition.y + (thresholdDistanceFeelingSafe * currentFleeDirection.normalized().y)
		feelingSafePositionDirection =  feelingSafePosition - selfGlobalPosition
		feelingSafePosition = Vector2(x, y)
	else:
		feelingSafePosition = selfGlobalPosition
		feelingSafePositionDirection =  threatGlobalPosition - selfGlobalPosition
	
func EvadeThreat(selfSpeed:float, selfDrag:float, targetVelocity:Vector2, selfGlobalPosition:Vector2, threatPosition:Vector2,
							selfCharacterBody2D:CharacterBody2D) -> void:
	var distanceToTarget : Vector2 = threatPosition - selfGlobalPosition
	var timeToReachTargetPosition : float = distanceToTarget.length() / selfSpeed
	var futureThreatPosition : Vector2 	= threatPosition + targetVelocity * timeToReachTargetPosition
	
	Flee(selfSpeed, selfDrag, selfGlobalPosition, futureThreatPosition, selfCharacterBody2D)
