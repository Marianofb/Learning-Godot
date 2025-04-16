class_name EnemyMovement extends CharacterBody2D

# AStart
@export_category("AStar Components")

@export_category("Pathing Variables")
@export var thresholdDistanceToNextNode : float = 20
@export var thresholdDistanceToOnArrival : float = 125
@export var thresholdDistanceFeelingSafe : float = 300
@export var distanceToDestination : float 
var distanceToNextPathPosition : float
var currentPath : Array[Vector2i]
var ahead : Vector2 
var ahead2 : Vector2
var obstacleAvoidanceForce : Vector2 = Vector2.ZERO
var otherNPCAvoidanceForce : Vector2 = Vector2.ZERO
var feelingSafePosition : Vector2 = Vector2.ZERO
var feelingSafePositionDirection : Vector2 = Vector2.ZERO
var nextPointPosition : Vector2 = Vector2.ZERO
var lastTargetPosition : Vector2 = Vector2.ZERO

@export_category("Components")
var enemy: Enemy
@onready var selfCollisionShape2D : CollisionShape2D = get_node("CollisionShape2D")

func _ready() -> void:
	enemy = get_parent()
	await enemy.ready
	RequestPathToTarget(enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition())

func _process(delta: float) -> void:
	RequestPathToTarget(enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition())
	
func _physics_process(delta: float) -> void:
	queue_redraw()	
	## Avoidance Force Type ##
	SetObstacleAvoidanceForce(enemy.GetSelfGlobalPosition(), enemy.GetSelfCharactearBody2D(), enemy.GetAvoidanceRadius(), enemy.GetSelfSpeed())
	SetOtherNPCAvoidanceForce(enemy.GetDrag(), enemy.GetNeighbours(), enemy.GetCollsionRadius())
	
	## Movemenet Type ## 
	#Seek(enemy.GetSelfSpeed(),enemy.GetDrag(), enemy.GetSelfCharactearBody2D(), enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition())
	Seek(enemy.GetSelfSpeed(),enemy.GetDrag(), enemy.GetSelfCharactearBody2D(), enemy.GetSelfGlobalPosition(), enemy.thing.global_position)
	#FollowPath(enemy.GetSelfSpeed(),enemy.GetDrag(), enemy.GetSelfCharactearBody2D(), enemy.GetSelfGlobalPosition())
	#GoToFutureTargetPosition(enemy.GetSelfSpeed(), enemy.GetDrag(), enemy.GetTargetVelocity(),enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition(), enemy.GetSelfCharactearBody2D())
	#Flee(enemy.GetSelfSpeed(),enemy.GetDrag(), enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition(), enemy.GetSelfCharactearBody2D())
	#EvadeThreat(enemy.GetSelfSpeed(), enemy.GetDrag(), enemy.GetTargetVelocity(),enemy.GetSelfGlobalPosition(), enemy.GetTargetGlobalPosition(), enemy.GetSelfCharactearBody2D())		

func _draw() -> void:
	#DrawPathPoints()
	#DrawAvoidanceRadius()
	DrawAhead()
	DrawCollisionRadius()
	pass

func RequestPathToTarget(selfPostion, targetPostion):	
	currentPath = enemy.game.pathManager.GetPathToTarget(selfPostion, targetPostion)

func Collision() -> bool:
	if get_slide_collision_count() > 0:
		print('ColisionObstaculo')
		return true
		
	return false

#Avoidance Force for others NPCs
func SetOtherNPCAvoidanceForce(drag : float, neighbours : Array[Node], collisionRadius : float) -> Vector2:
	var shortestTime : float = INF
	var target : Enemy = null
	var targetCollisionRadius: float
	var radiusSum : float = 0
	var targetMinSeparation : float 
	var targetCharacterBody2D : CharacterBody2D
	var targetRelativePos : Vector2
	var targetRelativeVel : Vector2
	var targetDistance : float 
	
	for neighbour : Enemy in neighbours:
		if neighbour == enemy:
			continue
		
		#Calculate the time to collision
		targetCollisionRadius = neighbour.GetCollsionRadius()
		radiusSum = targetCollisionRadius + collisionRadius
		targetCharacterBody2D = neighbour.GetSelfCharactearBody2D()
		var relativePos : Vector2 = targetCharacterBody2D.global_position - enemy.GetSelfCharactearBody2D().global_position
		var relativeVel : Vector2 = targetCharacterBody2D.velocity - enemy.GetSelfCharactearBody2D().velocity
		var relativeSpeed : float = relativeVel.length()
		
		#If collision (negative), no collision (positive or zero)
		var timeToCollision : float  = relativePos.dot(relativeVel) / (relativeSpeed * relativeSpeed)		
		
		#Check if there is going to be a collision at all
		var distance : float = relativePos.length()
		var minSeparation : float = distance + relativeSpeed * timeToCollision
		
		if minSeparation > radiusSum:
			continue
		
		#Check if it is the shortest time
		if timeToCollision < 0 and timeToCollision < shortestTime:
			#Store the target and its variables
			shortestTime = timeToCollision
			target = neighbour
			targetMinSeparation = minSeparation
			targetDistance = distance
			targetRelativePos = relativePos
			targetRelativeVel = relativeVel
	
	#If the neighbours are too far than we have no target
	if target == null:
		otherNPCAvoidanceForce = Vector2.ZERO
		return Vector2.ZERO
	
	var avoidanceDirection : Vector2
	#If we are already colliding or we are gonna hit
	#Else calculate the relative future position of the target
	if targetDistance < radiusSum:
		otherNPCAvoidanceForce = -targetRelativePos
		var positionHash = int(enemy.global_position.x * 1000) % 2 
		var sideDirection = Vector2(-targetRelativePos.y, targetRelativePos.x)
		if positionHash == 0:
			otherNPCAvoidanceForce = otherNPCAvoidanceForce + sideDirection
		else:
			otherNPCAvoidanceForce = otherNPCAvoidanceForce - sideDirection
	else:
		var futurePos = targetRelativePos - targetRelativeVel * shortestTime
		otherNPCAvoidanceForce = -futurePos.normalized()
	
	return otherNPCAvoidanceForce


#Avoidance Force for walls or obstacles
func SetObstacleAvoidanceForce(selfGlobalPosition:Vector2, selfCharacterBody2D:CharacterBody2D, avoidanceRadius:float, selfSpeed : float) -> Vector2:
	var dynamicLength : float = selfCharacterBody2D.velocity.length() / selfSpeed
	ahead = selfCharacterBody2D.velocity.normalized() * avoidanceRadius 
	ahead2 = selfCharacterBody2D.velocity.normalized() * (avoidanceRadius * 0.5)
	var closestCollider : Node2D = GetClosestObstacle()
	
	if (closestCollider):
		obstacleAvoidanceForce +=  closestCollider.global_position + ((ahead + ahead2)  * enemy.GetMaxAvoidanceForce())
	else:
		obstacleAvoidanceForce = Vector2.ZERO
		
	return obstacleAvoidanceForce

func GetClosestObstacle() -> Node2D:
	var closestCollider : Node2D = null
	var distanceCollider : float = INF
	var distanceToClosestCollider : float = INF
	
	var aheadHit : Node2D = RaycastHitsObstacle(global_position, ahead) 
	var aheadHit2 : Node2D = RaycastHitsObstacle(global_position, ahead2)
	
	if (closestCollider == null ||  distanceCollider < distanceToClosestCollider):
		if aheadHit:
			closestCollider = aheadHit
		elif aheadHit2 :
			closestCollider = aheadHit2
			
		distanceToClosestCollider = distanceCollider
		
	return closestCollider

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
	
## SEEK ## 	
func Seek(selfSpeed:float, selfDrag:float, selfCharacterBody2D:CharacterBody2D, selfGlobalPosition:Vector2, destinationGlobalPosition:Vector2, ) -> void:
	var currentChaseDirection = destinationGlobalPosition - selfGlobalPosition
	enemy.SetSelfCurrentDirection(currentChaseDirection)
	
	#Steering Behaviour
	var desiredVelocity : Vector2 = currentChaseDirection.normalized() * selfSpeed
	
	#OnArrival
	distanceToDestination = selfGlobalPosition.distance_to(lastTargetPosition)
	if(distanceToDestination <= thresholdDistanceToOnArrival):
		desiredVelocity = currentChaseDirection.normalized() * selfSpeed * (distanceToDestination / thresholdDistanceToOnArrival)
	
	var steering : Vector2 = (desiredVelocity - selfCharacterBody2D.velocity) / selfDrag

	var totalForce : Vector2 = steering + obstacleAvoidanceForce + otherNPCAvoidanceForce
	selfCharacterBody2D.velocity += totalForce
	selfCharacterBody2D.velocity =  selfCharacterBody2D.velocity.normalized() * clamp(selfCharacterBody2D.velocity.length(), 0, selfSpeed)
	
	selfCharacterBody2D.move_and_slide()

func FollowPath(selfSpeed:float, selfDrag:float, selfCharacterBody2D:CharacterBody2D, selfGlobalPosition:Vector2):
	if !currentPath.is_empty():
		lastTargetPosition =  enemy.game.tileMapLayer.map_to_local(currentPath.back())
		nextPointPosition = enemy.game.tileMapLayer.map_to_local(currentPath.front())
		distanceToNextPathPosition =  selfGlobalPosition.distance_to(nextPointPosition)
		if distanceToNextPathPosition < thresholdDistanceToNextNode:
			currentPath.remove_at(0)
	
	Seek(selfSpeed, selfDrag, selfCharacterBody2D, selfGlobalPosition, nextPointPosition, )		

func GoToFutureTargetPosition(selfSpeed:float, selfDrag:float, targetVelocity:Vector2, selfGlobalPosition:Vector2, targetGlobalPosition:Vector2,
							selfCharacterBody2D:CharacterBody2D) -> void:
	var distanceToTarget : Vector2 = targetGlobalPosition - selfGlobalPosition
	var timeToReachTargetPosition : float = distanceToTarget.length() / selfSpeed
	var futureTargetPosition : Vector2 	= targetGlobalPosition + targetVelocity * timeToReachTargetPosition
	
	Seek(selfSpeed, selfDrag, selfCharacterBody2D, selfGlobalPosition, futureTargetPosition)

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
	selfCharacterBody2D.velocity += steering + obstacleAvoidanceForce + otherNPCAvoidanceForce
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

func DrawAvoidanceRadius() -> void:
	var colorRadius =  Color(0.5, 0.5, 2, 0.5)
	draw_circle(Vector2.ZERO, enemy.GetAvoidanceRadius(), colorRadius)

func DrawCollisionRadius() -> void:
	var colorRadius =  Color(2, 0.5, 2, 0.5)
	draw_circle(Vector2.ZERO, enemy.GetCollsionRadius()*2, colorRadius)

func DrawPathPoints() -> void:
	for pathPoint in currentPath:
		var pointPosition = enemy.game.tileMapLayer.map_to_local(pathPoint)
		var square_size = 16 
		if pointPosition == lastTargetPosition:
			draw_rect(Rect2(pointPosition - enemy.GetSelfGlobalPosition() - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.BLUE)
		elif pointPosition == nextPointPosition:
			draw_rect(Rect2(pointPosition - enemy.GetSelfGlobalPosition() - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.GREEN)
		else:	
			draw_rect(Rect2(pointPosition - enemy.GetSelfGlobalPosition() - Vector2(square_size, square_size), Vector2(square_size, square_size)), Color.RED)

func DrawAhead() -> void:
	draw_line(Vector2.ZERO, ahead, Color.BLACK)
	draw_line(Vector2.ZERO, ahead2, Color.WEB_GREEN)
