class_name PlayerState extends State

const IDLE = "Idle"
const RUN = "Run"
const ATTACK = "Attack"

var player: Player

func _ready() -> void:
	player = get_parent().get_parent() as Player
	assert(player != null, "El nodo padre no es de tipo Player. Verifica la jerarquía de nodos.")
