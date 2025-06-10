extends Panel

@export_group("typewriter")
@export var interval : float

@onready var text_field : RichTextLabel = $MarginContainer/Text

var current_text : String = ""

var timer : Timer
var current_char_pointer = 0


func _ready() -> void:
	timer = Timer.new()
	
	timer.wait_time = interval
	timer.timeout.connect(type_letter)
	
	add_child(timer)


func type_letter() -> void:
	current_char_pointer += 1
	
	if current_char_pointer > current_text.length():
		timer.stop()
	
	text_field.text = current_text.substr(0, current_char_pointer)



func trigger(new_text: String) -> void:
	current_text = new_text
	current_char_pointer = 0
	timer.start()
