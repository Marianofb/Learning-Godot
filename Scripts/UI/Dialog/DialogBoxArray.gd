extends Control

var text : Array[String] = ['Empire of the Summer Moon by S.C. Gwynne is a historical narrative that chronicles the rise and fall of the Comanche Nation, one of the most powerful and feared Native American tribes in history.',
							'The book focuses on the life of Quanah Parker, the last great Comanche chief, and his journey from a fierce warrior to a leader negotiating with the U.S. government during the tribes final years.',
							'The story also delves into the brutal and bloody conflict between the Comanches and the settlers, as well as the encroachment of European-American society on the land and culture of the indigenous peoples.',
							'Gwynne paints a vivid picture of the clash of civilizations, highlighting both the valor and tragedy of the Comanches, while also examining the broader context of the American West during the 19th century.',
							'The narrative emphasizes themes of survival, resistance, and the complex interactions between indigenous tribes and the expanding U.S. frontier.',
							]

@export_category("Dialog Variables")
#@export var index : int = 0
@export var speed : float = 5
@export var started : bool = false
@export var finished : bool = false
@export var dialogueQueue : Array[String] = []

# Dialog Components
@export_category("Dialog Components")
@onready var richTextLabel : RichTextLabel = get_node("RichTextLabel")

func _ready() -> void:
	hide()

func _process(delta):
	StartDialog()
	LoadDialog()

func StartDialog() -> void:
	if(Input.is_action_just_pressed('F') && started == false):
		#Logica
		started = true
		finished = false
		ReadyDialog(text)
		richTextLabel.parse_bbcode(Dequeue())
		richTextLabel.visible_characters = 0
		#Animacion
		DeleteTweens()
		show() 
		var tween : Tween = get_tree().create_tween()  # Crear el tween
		tween.tween_property(richTextLabel, 'visible_characters', richTextLabel.get_total_character_count(), speed)

func ReadyDialog(text: Array[String]) -> void:
	for line in text:
		Enqueue(line)

func LoadDialog() -> void:
	if(Input.is_action_just_pressed("enter") && started == true):
		if(!QueueEmpty() && finished == false):
			#Logica
			richTextLabel.parse_bbcode(Dequeue())
			richTextLabel.visible_characters = 0
			#Animacion
			DeleteTweens()
			var tween : Tween = get_tree().create_tween()  # Crear el tween
			tween.tween_property(richTextLabel, 'visible_characters', richTextLabel.get_total_character_count(), speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)	
		else:
			EndDialog()

func EndDialog() -> void:
	started = false
	finished = true
	richTextLabel.clear()
	hide()
	
func DeleteTweens() -> void: 
	for t in get_tree().get_processed_tweens():
		t.kill() 
	
func Enqueue(sentence:String) -> void:
	dialogueQueue.push_back(sentence)

func Dequeue() -> String:
	if(!QueueEmpty()):
		return dialogueQueue.pop_front()
	else:
		return ""
		
func QueueEmpty() -> bool:
	return dialogueQueue.size() == 0
