class_name Enemy extends Node2D

## GAME ## 
var game : Game = null

## TRACKER ##
@export_category("Tracker")
@export var trackerSpeed : float = 0
var tracker : Node2D = null
var trackerSprite2D: Sprite2D
var trackerCharacterBody2D: CharacterBody2D

## STATE ##
@export_category("State")
@export var currentState : String = ""

@export_category("Movement Variables")
@export var currentDirection : Vector2
@export var speed : float = 125
@export var drag : float = 25
@export var maxAvoidanceForce : float = 2
@export var avoidanceRadius : float = 25

@export_category("Pathing Variables")
@export var thresholdDistanceToNextNode : float = 20
@export var thresholdDistanceToOnArrival : float = 125
@export var thresholdDistanceFeelingSafe : float = 300
@export var distanceToDestination : float 

#Detection Variables
@export_category("FOV Variables")
@export var angleTheshold: float = 60.0 # Ángulo de visión en grados
@export var radius: float = 100 # Radio de visión
@export var currentDetectionState : String = ""
@export var totalDetection: float = 0
@export var minTotalDetection: float = 0
@export var maxTotalDetection: float = 100
@export var detectionIncrease: float = 3
@export var detectionDecay: float = -1
#Detection Phases
@export var normalDetectionThreshold: float = 0
@export var suspiciousDetectionThreshold: float = 25
@export var alertDetectionThreshold: float = 75
const NORMAL : String = "Normal"
const SUSPICIOUS : String = "Souspicius"
const ALERT : String = "Alert"

@export_category("Components")
@onready var characterBoyd2D : CharacterBody2D = get_node('CharacterBody2D')
@onready var fov : EnemyFOV = get_node('CharacterBody2D/FOV')

@export_category("Target")
var target : Player = null

func _ready() -> void:
	await owner._ready()
	game = owner as Game
	target = game.player
	
	InitializeEnemy()
		
func _process(delta: float) -> void:	
	UpdateTotalDetection()
	UpdateDetectionPhase()
	pass

func InitializeEnemy() -> void:
	currentDirection = Vector2.RIGHT

func InstantiateTracker() -> void:
	tracker = Node2D.new()
	tracker.name = "Tracker"
	trackerSprite2D = Sprite2D.new()
	trackerCharacterBody2D = CharacterBody2D.new()
	tracker.add_child(trackerSprite2D)
	tracker.add_child(trackerCharacterBody2D)
	add_child.call_deferred(tracker)
	trackerCharacterBody2D.position = characterBoyd2D.position
	trackerSpeed = speed * 1.5

### ENEMY MOVEMENT VARIABLES ###
func GetSelfSpeed() -> float:
	return speed
	
func GetDrag() -> float:
	return drag
	
func GetMaxAvoidanceForce() -> float:
	return maxAvoidanceForce
	
func GetAvoidanceRadius() -> float:
	return avoidanceRadius

func GetSelfCurrentDirection() -> Vector2:
	return currentDirection
	
func SetSelfCurrentDirection(direction:Vector2) -> void:
	currentDirection = direction
	
### STATE ###
func GetCurrentState() -> String:
	return currentState
	
func SetCurrentState(state:String) -> void:
	currentState = state

### FOV VARIABLES ###
func GetFovAngleTheshold() -> float:
	return angleTheshold

func GetFovRadius() -> float:
	return radius

func GetCurrentDetectionState() -> String:
	return currentDetectionState

func SetDetectionCurrentState(state:String) -> void:
	currentDetectionState = state

func GetTotalDetection() -> float:
	return totalDetection

func SetTotalDetection(amount:float) -> void:
	totalDetection = amount

func UpdateTotalDetection() -> void:
	if(fov.TargetDetected(GetTargetGlobalPosition(), GetSelfCurrentDirection(), 
						GetSelfGlobalPosition())):
		totalDetection = clamp(totalDetection + detectionIncrease, minTotalDetection , maxTotalDetection)
	else:
		totalDetection = clamp(totalDetection + detectionDecay, minTotalDetection , maxTotalDetection)	

func GetNormalDetectionThreshold() -> float:
	return normalDetectionThreshold

func GetSuspicousDetectionThreshold() -> float:
	return suspiciousDetectionThreshold

func GetAlertDetectionThreshold() -> float:
	return alertDetectionThreshold

func UpdateDetectionPhase() -> void:
	if(GetTotalDetection() >= GetAlertDetectionThreshold()):
		SetDetectionCurrentState(ALERT)
	elif(GetTotalDetection() >= GetSuspicousDetectionThreshold()):
		SetDetectionCurrentState(SUSPICIOUS)
	elif(GetTotalDetection() == GetNormalDetectionThreshold()):
		SetDetectionCurrentState(NORMAL)

### TRACKER ###
func GetTrackerGlobalPosition() -> Vector2:
	return trackerCharacterBody2D.global_position

func GetTrackerSpeed() -> float:
	return trackerSpeed
	
func GetTrackerCharactearBody2D() -> CharacterBody2D:
	return trackerCharacterBody2D 

### TARGET ###
func GetTargetGlobalPosition() -> Vector2:
	return target.GetCharacterBody2D().global_position

func GetTargetVelocity() -> Vector2:
	return target.GetCharacterBody2D().velocity

### ENEMY COMPONENTS ###
func GetSelfGlobalPosition() -> Vector2:
	return characterBoyd2D.global_position
	
func GetSelfCharactearBody2D() -> CharacterBody2D:
	return characterBoyd2D
	
