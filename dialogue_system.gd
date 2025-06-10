extends Panel

@export_group("typewriter")
@export var interval : float

@export_group("tweening")
@export var tween_speed : float

@onready var text_field : RichTextLabel = $MarginContainer/Text

var timer : Timer
var current_text : String = ""
var current_dialouge_entry : DialogueEntry
var current_char_pointer := 0
var in_screen := false
var json_data
var dialouge_entries = []
var current_choices = []


func _ready() -> void:
	
	# setup timer
	timer = Timer.new()
	timer.wait_time = interval
	timer.timeout.connect(type_letter)
	add_child(timer)
	
	# load json
	load_json_dialogue()


func type_letter() -> void:
	# increase char pointer
	current_char_pointer += 1
	
	if current_char_pointer > current_text.length():
		timer.stop()
	
	# update text field
	text_field.text = current_text.substr(0, current_char_pointer)


func _process(delta: float) -> void:
	# tween
	var window_height = get_window().size.y
	var target_y = window_height - (size.y if in_screen else 0.0)
	position = lerp(position, Vector2.DOWN * target_y, tween_speed * delta)
	
	
	# pressed 'e' and dialogue panel is in screen
	if Input.is_action_just_pressed("dialogue_accept") and \
		abs(position.y - target_y) < 0.1:
		
		# advance dialogue entry
		current_dialouge_entry = dialouge_entries[current_dialouge_entry.id + 1]
		# update text
		current_text = parse_content(current_dialouge_entry.content)
		
		current_char_pointer = 0
		timer.start()
		


func trigger(key: String) -> void:
	var start_idx = -1
	
	# find start element
	for i in range(0, dialouge_entries.size()):
		var entry = dialouge_entries[i]
		if entry.key == key:
			start_idx = i
			break
	
	# check if anything was found
	if start_idx < 0:
		push_error("can't find dialogue entry at key \"" + key + "\"")
		return
	
	current_dialouge_entry = dialouge_entries[start_idx]
	current_text = current_dialouge_entry.content
	
	in_screen = true
	current_char_pointer = 0
	timer.start()


func load_json_dialogue() -> void:
	# parse json file
	var file_string = FileAccess.get_file_as_string(Util.JSON_DIALOGUE_PATH)
	json_data = JSON.parse_string(file_string) as Dictionary
	
	# create dialogue entries
	for i in json_data.keys():
		var dialogue_entry = DialogueEntry.from_json(int(i), json_data[i])
		dialouge_entries.push_back(dialogue_entry)


func parse_content(content: String) -> String:
	# basically checking for choice
	if not content.contains("["):
		return content
	
	# find choice string
	var choices = content.substr(content.find("[")+1, content.find("]")-1)
	# populate choice array
	current_choices = choices.split(",")
	
	# return stripped content
	return content.replace(content.substr(content.find("["), content.find("]")), "")
