extends EnemyState

func enter(previous_state_path: String, data := {}) -> void:
	enemy.SetCurrentState(CHASE)
	
func physics_update(_delta: float) -> void:
	pass
