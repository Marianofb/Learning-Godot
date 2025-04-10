extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.currentState = ATTACK
	PlayPunch()
	#PlayHeadButting()
	player.SetCurrentDirection(player.GetMouseCurrentDirection())

func physics_update(_delta: float) -> void:
	if !player.GetAttacking():
			finished.emit(IDLE)
			
			
func PlayPunch():
	if Input.is_action_pressed("left-click"):
		player.SetAttacking(true)
		player.GetAnimationController().PlayAnimation("Punch", player.GetMouseCurrentDirection())
		
#func PlayHeadButting():
	#if Input.is_action_pressed("right-click"):
		#player.attacking = true
		#print("HeadButting Activated")
		#player.animation.PlayAnimation("HeadButting", player.mouseDirection)
