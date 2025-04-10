class_name Game extends Node2D

@onready var player : Node2D

const LAYER_MASK_OBSTACLE = 2

func _ready() -> void:
	player = get_node('Player')

func GetLayerMaskObstacle() -> int:
	return LAYER_MASK_OBSTACLE
