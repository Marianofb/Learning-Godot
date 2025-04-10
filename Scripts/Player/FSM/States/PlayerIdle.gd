extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.SetCurrentState(IDLE)
	player.GetAnimationController().PlayAnimation("Idle", player.GetCurrentDirection())

func physics_update(_delta: float) -> void:
	var inputDirection = Input.get_vector("west", "east", "north", "south")
	
	if !player.AttackInputPressed():
		if inputDirection != Vector2.ZERO:
			finished.emit(RUN)
	else:
		finished.emit(ATTACK)
