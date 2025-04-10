class_name PlayerAnimationController extends Node

var player: Player

func _ready() -> void:
	player = get_parent() as Player
	assert(player != null, "El nodo padre no es de tipo Player. Verifica la jerarquía de nodos.")
	
func PlayAnimation (animationName, vector):
	var parametersBlend = "parameters/" + animationName + "/blend_position"
	player.GetAnimationTree().set(parametersBlend, vector)
	player.GetAnimationTree().get("parameters/playback").travel(animationName)
	#print ("Length Of Animation ", animationName, ": ", GetAnimationLength(animationName))

func GetAnimationLength(animationName):
	var animationName_LowerCase = animationName.to_lower() + "_south"
	var animationLength = player.GetAnimationPlayer().get_animation(animationName_LowerCase).length

	return animationLength
	
func AttackAnimationFinished():
	player.SetAttacking(false)
