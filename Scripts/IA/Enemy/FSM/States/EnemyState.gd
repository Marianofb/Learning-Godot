class_name EnemyState extends State

const IDLE = "Idle"
const ROUTINE = "Routine"
const CHASE = "Chase"
const ATTACK = "Attack"
const FLEE = "Flee"

var enemy: Enemy

func _ready() -> void:
	enemy = get_parent().get_parent() as Enemy
