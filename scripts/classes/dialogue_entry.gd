extends Node

class_name DialogueEntry


enum DialogueType {
	TEXT,
	YESNO,
	CHOICE,
	END
}

enum DialogueCondition {
	YES,
	NO,
	ONE,
	TWO,
	THREE
}


var id : int
var key : String
var type : DialogueType
var content : String
var condition : DialogueCondition


static func from_json(id : int, json_data : Dictionary) -> DialogueEntry:
	var ret = DialogueEntry.new()
	
	ret.id = id
	ret.key = json_data["KEY"]

	match (json_data["TYPE"]):
		"TEXT": ret.type = DialogueType.TEXT
		"YESNO": ret.type = DialogueType.YESNO
		"CHOICE": ret.type = DialogueType.CHOICE
		"END": ret.type = DialogueType.END
	
	ret.content = json_data["CONTENT"]
	
	match (json_data["CONDITION"]):
		"YES": ret.condition = DialogueCondition.YES
		"NO": ret.condition = DialogueCondition.NO
		"1": ret.condition = DialogueCondition.ONE
		"2": ret.condition = DialogueCondition.TWO
		"3": ret.condition = DialogueCondition.THREE
	
	return ret


func print_entry() -> void:
	print("id: " + str(id) + ", key: " + key + ", type: " + str(type) + ", content: " + content + ", condition: " + str(condition))
