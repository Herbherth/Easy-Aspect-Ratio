@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	dock = preload("res://addons/easyAspectRatio/WindowOptions.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Aspect Ratio")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(dock)
	dock.free()

