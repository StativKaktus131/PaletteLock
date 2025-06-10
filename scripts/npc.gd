extends StaticBody3D

@export_group("art")
@export var tex : Texture2D
@export_group("dialogue")
@export var text : String

@onready var sprite = $Sprite3D


func _ready() -> void:
	sprite.texture = tex
	
