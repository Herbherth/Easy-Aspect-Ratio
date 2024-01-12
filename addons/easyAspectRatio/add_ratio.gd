@tool
extends PopupPanel

# This code is responsible for the popup that creates a new aspect ratio

signal created_new(file_path: String)

var file_name: String
var width: float = 1
var height: float = 1

func _on_popup_hide() -> void:
	queue_free()


func _on_create_pressed() -> void:
	var new_ratio := AspectRatioModel.new(file_name, width, height)
	if not file_name:
		file_name = "%sx%s" %[width, height]
	
	var resource_file = "res://addons/easyAspectRatio/aspectRatios/%s.tres" %file_name
	ResourceSaver.save(new_ratio, resource_file)
	created_new.emit(resource_file)
	queue_free()


func _on_line_edit_text_changed(new_text: String) -> void:
	file_name = new_text


func _on_spin_box_value_changed(value: float) -> void:
	width = value


func _on_height_value_changed(value: float) -> void:
	height = value
