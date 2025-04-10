class_name EnemyFOV
extends Node2D

@export_category("Components")
var enemyMovement: EnemyMovement

func _ready() -> void:
	enemyMovement = get_parent()
	pass

func _process(delta: float) -> void:	
	queue_redraw()

func _draw() -> void:
	#DrawRadius()
	#DrawFOV()
	pass

func TargetDetected( targetGlobalPosition:Vector2, selfCurrentDirection:Vector2, selfGlobalPosition:Vector2) -> bool:
	var directionToTarget = (targetGlobalPosition - selfGlobalPosition)
	var dotProduct = selfCurrentDirection.normalized().dot(directionToTarget.normalized())
	#dotProductoAngle --> It returns the angle between two vectors in radians
	var dotProductoAngle = acos(dotProduct)
	var distanceTargetToMe = targetGlobalPosition.distance_to(selfGlobalPosition)
	var angleThesholdRad = deg_to_rad(enemyMovement.enemy.GetFovAngleTheshold())
	
	return dotProductoAngle <= angleThesholdRad  and distanceTargetToMe <= enemyMovement.enemy.GetFovRadius()

func UpdateTotalDetection():
	pass

func DrawRadius() -> void:
	#BLUE
	var colorRadius =  Color(0, 0, 1, 0.2)
	if !TargetDetected(enemyMovement.enemy.GetTargetGlobalPosition(), enemyMovement.enemy.GetSelfCurrentDirection(), enemyMovement.enemy.GetSelfGlobalPosition()):
		#RED
		colorRadius =  Color(1, 0, 0, 0.2)
		
	draw_circle(Vector2.ZERO, enemyMovement.enemy.GetFovRadius(), colorRadius)

func DrawFOV() -> void:
	var negativeAngle = -enemyMovement.enemy.GetFovAngleTheshold()
	var positiveAngle = enemyMovement.enemy.GetFovAngleTheshold()

	var negativeVector = enemyMovement.enemy.currentDirection.normalized().rotated(deg_to_rad(negativeAngle)) * enemyMovement.enemy.GetFovRadius()
	var positiveVector = enemyMovement.enemy.currentDirection.normalized().rotated(deg_to_rad(positiveAngle)) * enemyMovement.enemy.GetFovRadius()

	draw_line(Vector2.ZERO, negativeVector,  Color(0.545098, 0, 0.545098, 1))
	draw_line(Vector2.ZERO, positiveVector,  Color(0.545098, 0, 0.545098, 1))
