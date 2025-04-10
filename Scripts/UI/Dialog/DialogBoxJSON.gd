extends Control

#Dialog Components
@export_category("Dialog Components")
@export var data = {}
@export var speed : float = 1
@onready var richTextLabel: RichTextLabel = get_node("RichTextLabel")
@onready var vBoxContainer: VBoxContainer = get_node("ScrollContainer/VBoxContainer")
@onready var templateButton: Button = get_node("ScrollContainer/VBoxContainer/Button")

func _ready():
	templateButton.hide()  # Hide the button template
	LoadJson("res://Dialogs/First.json")
	NpcGreeting()
	ConfigureOptions()

func LoadJson(path : String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if (file):
		var fileContent = file.get_as_text()
		data = JSON.parse_string(fileContent)
	else:
		print('ERROR: path doesnt exist. ')
	pass

func NpcGreeting():
	if (data.has('npcGreeting')):
		richTextLabel.parse_bbcode(data['npcGreeting'])

func ConfigureOptions() -> void:
	var optionNumber : int = 1
	if(data.has('options')):
		for option in data['options']:
			var button : Button = templateButton.duplicate()
		
			if(!option.has('closeDialog')):
				button.text = str(optionNumber) + ". " + option['text']
				optionNumber += 1			
			else:
				button.text = option['text']
		
			button.show()
			button.pressed.connect(func(): HandleDialogOption(option))
			vBoxContainer.add_child(button)

func EnterTrade():
	print('Enter trade menu.')
	
func Leave():
	print("Exit dialog.")
	hide()

func Attack():
	print("Attack the cunt.")
	hide()

func DeleteTweens() -> void: 
	for t in get_tree().get_processed_tweens():
		t.kill() 
	
func HandleDialogOption(option):
	if(option.has('response')):
		richTextLabel.visible_characters = 0
		richTextLabel.parse_bbcode(option['response'])
		DeleteTweens()
		var tween : Tween = get_tree().create_tween()  # Crear el tween
		tween.tween_property(richTextLabel, 'visible_characters', richTextLabel.get_total_character_count(), speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)	
	
	if(option.has('action')):
		if(option['action'] == 'trade'):
			EnterTrade()
		
	if(option.has('closeDialog')):
		if(option['closeDialog'] == true && option['text'] == 'Leave'):
			Leave()
		elif(option['closeDialog'] == true && option['text'] == 'Attack'):
			Attack()
