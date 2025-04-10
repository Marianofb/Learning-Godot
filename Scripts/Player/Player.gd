class_name Player extends Node2D  

# Health 
@export_category("Health")
@export var currentHealth: float = 100.0
@export var maxHealth: float = 100.0
@export var minHealth: float = 0
@export var healthRecoveryRate: float = 0.5
	
# Stamina 
@export_category("Stamina")
@export var currentStamina: float = 50.0
@export var maxStamina: float = 50.0
@export var staminaRecoveryRate: float = 3.0

# Movement Variables
@export_category("Movement Variables")
@export var speed: float = 150
@export var currentDirection: Vector2 = Vector2.ZERO 
@export var attacking: bool = false

# Mouse
@export_category("Mouse")
@export var currentMouseDirection: Vector2 = Vector2.ZERO 

# State
@export_category("State")
@export var currentState : String = ""
	
#Player Components
@export_category("Player Components")
@onready var characterBody2D : CharacterBody2D = get_node('CharacterBody2D')
@onready var animationController : PlayerAnimationController =  get_node('AnimationController')
@onready var animatedSprite2D : AnimatedSprite2D = get_node('CharacterBody2D/AnimatedSprite2D')
@onready var animationTree : AnimationTree = get_node('CharacterBody2D/AnimationTree')
@onready var animationPlayer : AnimationPlayer= get_node('CharacterBody2D/AnimationPlayer')

func _process(delta):
	SetMouseCurrentDirection()

func AttackInputPressed():
	if Input.is_action_pressed("left-click") || Input.is_action_pressed("right-click"):
		return true
	else:
		return false
				
### HEALTH ###
func GetMaxHealth() -> float:
	return maxHealth

func GetMinHealth() -> float:
	return minHealth

func GetHealthRecoveryRate() -> float:
	return healthRecoveryRate

func GetCurrentHealth() -> float:
	return currentHealth
	
func UpdateCurrentHealth() -> void:
	currentHealth = clamp(currentHealth + healthRecoveryRate, minHealth, maxHealth)

### STAMINA ###
func GetCurrentStamina() -> float: 
	return currentStamina
	
func GetMaxStamina() -> float: 
	return maxStamina
	
func GetStaminaRecoveryRate() -> float: 
	return staminaRecoveryRate

### MOVEMENT VARIABLES ###
func GetSpeed() -> float: 
	return speed
	
func GetCurrentDirection() -> Vector2: 
	return currentDirection

func SetCurrentDirection(newDirection:Vector2) -> void:
	currentDirection = newDirection
	
func GetAttacking() -> bool:
	return attacking
	
func SetAttacking(activate:bool) -> void:
	attacking = activate
	
### MOUSE ###
func GetMouseCurrentDirection() -> Vector2:
	return currentMouseDirection

func SetMouseCurrentDirection():
	currentMouseDirection = (get_viewport().get_mouse_position() - characterBody2D.global_position).normalized()

### STATE ###
func GetCurrentState() -> String:
	return currentState
	
func SetCurrentState(state:String) -> void:
	currentState = state

### PLAYER COMPONENTS ###
func GetCharacterBody2D() -> CharacterBody2D:
	return characterBody2D
	
func GetAnimationController() -> PlayerAnimationController:
	return animationController

func GetAnimatedSprite2D() -> AnimatedSprite2D:
	return animatedSprite2D	
	
func GetAnimationTree() -> AnimationTree:
	return animationTree
	
func GetAnimationPlayer() -> AnimationPlayer:
	return animationPlayer
