#Code from gdquest tutorial
#https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/

class_name EnemyStateMachine extends Node

@export var initial_state: State = null
@export var current_state : String

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

func _ready() -> void:
	#find_children("*", "State", false):
	#			pattern: String = "*", type: String = "State", recursive = false:
	for state_node: State in find_children("*", "State", false):
		state_node.finished.connect(_transition_to_next_state)

	await owner.ready
	state.enter("")
	

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	current_state = target_state_path
	#print("Transitioning to:", current_state)
	if not has_node(target_state_path):
		#printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
