extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.SetCurrentState(RUN)
	player.GetAnimationController().PlayAnimation("Run", player.GetCurrentDirection())

func physics_update(_delta: float) -> void:
	player.GetAnimationController().PlayAnimation("Run", player.GetCurrentDirection())
	var inputDirection = Input.get_vector("west", "east", "north", "south")
	player.GetCharacterBody2D().velocity = inputDirection * player.GetSpeed()  # Usa la propiedad nativa `velocity` de CharacterBody2D
	
	if !player.AttackInputPressed():
		if inputDirection == Vector2.ZERO:
			finished.emit(IDLE)
		else:
			player.SetCurrentDirection(inputDirection.normalized())
			player.characterBody2D.move_and_slide()
	else:
		finished.emit(ATTACK)
