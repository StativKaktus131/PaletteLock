extends Panel

@export_group("typewriter")
@export var interval : float

@export_group("tweening")
@export var tween_speed : float

@onready var text_field : RichTextLabel = $MarginContainer/Text

@onready var choice_container : VBoxContainer = $"../Choice Container"

var timer : Timer
var current_text : String = ""
var current_dialogue_entry : DialogueEntry
var current_char_pointer := 0
var in_screen := false
var json_data
var dialouge_entries = []
var current_choices = []

signal on_dialogue_ended


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
	
	
	# set visibility of choice panel
	choice_container.visible = current_choices.size() != 0
	
	# pressed 'e' and dialogue panel is in screen and not pressing choices
	if Input.is_action_just_pressed("dialogue_accept") and \
		abs(position.y - target_y) < 0.1 and current_choices.size() == 0:
		step_through_dialogue()
		


func step_through_dialogue() -> void:
	set_dialog_at(current_dialogue_entry.id + 1)


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
	
	in_screen = true
	
	set_dialog_at(start_idx)


func load_json_dialogue() -> void:
	# parse json file
	var file_string = FileAccess.get_file_as_string(Util.JSON_DIALOGUE_PATH)
	json_data = JSON.parse_string(file_string) as Dictionary
	
	# create dialogue entries
	for i in json_data.keys():
		var dialogue_entry = DialogueEntry.from_json(int(i), json_data[i])
		dialouge_entries.push_back(dialogue_entry)


func parse_content(dialogue_entry: DialogueEntry) -> String:
	var content = dialogue_entry.content
	
	if dialogue_entry.type == DialogueEntry.DialogueType.CHOICE:
		# find choice string
		var choices = content.substr(content.find('[')+1, content.find(']')-content.find('[') - 1)
		# populate choice array
		current_choices = choices.split(",")
	
		# return stripped content
		return content.replace(content.substr(content.find("[")), "")
	
	elif dialogue_entry.type == DialogueEntry.DialogueType.YESNO:
		current_choices = ["YES", "NO"]
	
	else:
		current_choices = []
	
	return content


func set_dialog_at(idx: int) -> void:
	print("dialog at: " + str(idx))
	# advance dialogue entry
	current_dialogue_entry = dialouge_entries[idx]
	# update text
	current_text = parse_content(current_dialogue_entry)
	
	if current_dialogue_entry.type == DialogueEntry.DialogueType.END:
		in_screen = false
		on_dialogue_ended.emit()
		return
	elif current_dialogue_entry.type == DialogueEntry.DialogueType.GOTO:
		trigger(current_dialogue_entry.content)
		return
	
	if current_choices.size() != 0:
		for choice in current_choices:
			# add buttons
			var btn = Button.new()
			btn.text = choice
			btn.pressed.connect(func(): option_pressed(choice))
			choice_container.add_child(btn)
	
	current_char_pointer = 0
	timer.start()


func option_pressed(t: String) -> void:
	var idx = current_dialogue_entry.id
	
	var search = \
		DialogueEntry.DialogueCondition.YES if t == "YES" else \
		DialogueEntry.DialogueCondition.NO if t == "NO" else \
		DialogueEntry.DialogueCondition.ONE if t == current_choices[0] else \
		DialogueEntry.DialogueCondition.TWO if t == current_choices[1] else \
		DialogueEntry.DialogueCondition.THREE if t == current_choices[2] else \
		null
	
	
	for i in range(idx, dialouge_entries.size()):
		var entry = dialouge_entries[i]
		entry.print_entry()
		if entry.condition == search:
			print("entry condition: [" + str(entry.condition) + "]" + ", search: [" + str(search) + "]")
			set_dialog_at(i)
			current_choices = []
			
			# remove chillun
			for child in choice_container.get_children():
				choice_container.remove_child(child)
			
			return
		pass
