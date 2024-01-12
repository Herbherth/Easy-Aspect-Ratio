@tool
extends Resource
class_name AspectRatioModel

## Let it empty to auto complete as "ratio_width:ratio_height
@export var name: String
@export var ratio_width: float
@export var ratio_height: float

func _init(n := "", ratio_w:float = 1, ratio_h:float = 1) -> void:
	ratio_width = ratio_w
	ratio_height = ratio_h	
	name = n
