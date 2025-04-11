class_name Game extends Node2D

@export_category("Pathing Components")
@onready var tileMapLayer : TileMapLayer = get_node('TileMapLayer')
@onready var pathManager : Node2D = get_node('PathManager')

@onready var player : Node2D
@onready var children : Array[Node]

const LAYER_MASK_OBSTACLE = 2

func _ready() -> void:
	player = get_node('Player')
	SetChildren()

func SetChildren() -> void:
	children = get_children()

func GetChildren() -> Array[Node]:
	return children

func GetLayerMaskObstacle() -> int:
	return LAYER_MASK_OBSTACLE
