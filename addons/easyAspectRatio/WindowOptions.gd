@tool
extends Control

# Addon created by Herbherth

#region variables
@export var popUp_new_ratio: PackedScene
@export var aspect_ratios: Array[AspectRatioModel]

var save_settings: AspectRatioSaving = preload("res://addons/easyAspectRatio/pluginSettings.tres")
var original_fullscreen_mode
var original_mode_is_fullscreen := false
var stretch_options = ["disabled", "canvas_items", "viewport"] # the order matters
var stretch_aspect = ["ignore", "keep", "keep_width", "keep_height", "expand"] # the order matters
var stretch_mode = ["fractional", "integer"] # the order matters
var ratio := Vector2.ONE
#endregion

# Initialize the code
func _enter_tree() -> void:
	Set_AspectRatios()
	Set_from_settings()
	
	if not ProjectSettings.settings_changed.is_connected(Set_from_settings):
		ProjectSettings.settings_changed.connect(Set_from_settings)

# Get settings from "Project Setting" and set to addon to keep settings the same
func Set_from_settings() -> void:
	# Fullscreen
	original_fullscreen_mode = ProjectSettings.get("display/window/size/mode")
	
	original_mode_is_fullscreen = (
			original_fullscreen_mode == DisplayServer.WINDOW_MODE_FULLSCREEN 
			or original_fullscreen_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)
	
	($ScrollContainer/Itens/Options/fullscreen as CheckButton).button_pressed = original_mode_is_fullscreen
	
	# Always on top
	var always_top = ProjectSettings.get("display/window/size/always_on_top")
	($ScrollContainer/Itens/Options/Alwaysontop as CheckButton).button_pressed = always_top
	
	# Resizable
	var resizable = ProjectSettings.get("display/window/size/resizable")
	($ScrollContainer/Itens/Options/Resizable as CheckButton).button_pressed = resizable
	
	# VSync
	var vsync = ProjectSettings.get("display/window/vsync/vsync_mode")
	($ScrollContainer/Itens/Options/VSync as OptionButton).select(vsync)
	
	# Stretch Options
	var stretch_id: int = stretch_options.find(ProjectSettings.get("display/window/stretch/mode"), 0)
	($ScrollContainer/Itens/Stretch/StretchOptions as OptionButton).select(stretch_id)
	
	var stretch_aspect_id: int = stretch_aspect.find(ProjectSettings.get("display/window/stretch/aspect"), 0)
	($ScrollContainer/Itens/Stretch/StrecthAspect as OptionButton).select(stretch_aspect_id)
	
	var scale_mode_id: int = stretch_mode.find(ProjectSettings.get("display/window/stretch/scale_mode"), 0)
	($ScrollContainer/Itens/Stretch/ScaleMode as OptionButton).select(scale_mode_id)
	
	var scale_value: float = ProjectSettings.get("display/window/stretch/scale")
	($ScrollContainer/Itens/Stretch/Scale as SpinBox).value = scale_value
	($ScrollContainer/Itens/Stretch/ScaleSlider as Slider).value = scale_value
	
	# Size
	var w = ProjectSettings.get("display/window/size/viewport_width")
	var h = ProjectSettings.get("display/window/size/viewport_height")
	var screensize = save_settings.screensize
	if save_settings.screensize.x != w or save_settings.screensize.y != h:
		save_settings.screensize = Vector2i(w,h)
		save_settings.aspect_selected = 999
		ResourceSaver.save(save_settings)
		($ScrollContainer/Itens/AspectRatios/OptionButton as OptionButton).select(0)
		$ScrollContainer/Itens/Sizes/HWidth/horizontal.text = str(w)
		$ScrollContainer/Itens/Sizes/HHeight/vertical.text = str(h)


#region Other Options
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	var windowMode
	
	if toggled_on:
		windowMode = (
			original_fullscreen_mode if original_mode_is_fullscreen 
			else DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		windowMode = (
			original_fullscreen_mode if not original_fullscreen_mode 
			else DisplayServer.WINDOW_MODE_WINDOWED
		)
	
	ProjectSettings.set("display/window/size/mode", windowMode)
	ProjectSettings.save()


func _on_alwaysontop_toggled(toggled_on: bool) -> void:
	ProjectSettings.set("display/window/size/always_on_top", toggled_on)
	ProjectSettings.save()


func _on_resizable_toggled(toggled_on: bool) -> void:
	ProjectSettings.set("display/window/size/resizable", toggled_on)
	ProjectSettings.save()


func _on_v_sync_item_selected(index: int) -> void:
	ProjectSettings.set("display/window/vsync/vsync_mode", index)
	ProjectSettings.save()
#endregion


#region Stretch Options
func _on_stretch_options_item_selected(index: int) -> void:
	ProjectSettings.set("display/window/stretch/mode", stretch_options[index])
	ProjectSettings.save()


func _on_strecth_aspect_item_selected(index: int) -> void:
	ProjectSettings.set("display/window/stretch/aspect", stretch_aspect[index])
	ProjectSettings.save()


func _on_scale_value_changed(value: float) -> void:
	($ScrollContainer/Itens/Stretch/ScaleSlider as Slider).value = value
	ProjectSettings.set("display/window/stretch/scale", value)
	ProjectSettings.save()


func _on_scale_slider_value_changed(value: float) -> void:
	($ScrollContainer/Itens/Stretch/Scale as SpinBox).value = value


func _on_scale_mode_item_selected(index: int) -> void:
	ProjectSettings.set("display/window/stretch/scale_mode", stretch_mode[index])
	ProjectSettings.save()
#endregion


#region Aspect ratio options
func Set_AspectRatios() -> void:
	if save_settings.aspect_options.size() == 0:
		save_settings.aspect_options = aspect_ratios
		ResourceSaver.save(save_settings)
	else:
		aspect_ratios = save_settings.aspect_options
	
	var options = $ScrollContainer/Itens/AspectRatios/OptionButton as OptionButton
	options.clear()
	options.add_item("Custom", 999)
	var portrait = {}
	var landscape = {}
	
	for n in aspect_ratios.size():
		if aspect_ratios[n].name == "":
			aspect_ratios[n].name = "%s:%s" % [aspect_ratios[n].ratio_width, aspect_ratios[n].ratio_height]
		
		if aspect_ratios[n].ratio_width >= aspect_ratios[n].ratio_height:
			portrait[str(aspect_ratios[n].name)] = n
		else:
			landscape[str(aspect_ratios[n].name)] = n
	
	options.add_separator("Portrait")
	for n in portrait:
		options.add_item(n, portrait[n])
		
	options.add_separator("Landscape")
	for n in landscape:
		options.add_item(n, landscape[n])
	
	var idx = options.get_item_index(save_settings.aspect_selected)
	if save_settings.aspect_selected != 999:
		ratio = Vector2(aspect_ratios[save_settings.aspect_selected].ratio_width,aspect_ratios[save_settings.aspect_selected].ratio_height)
	options.select(idx)
	_on_option_button_item_selected(idx)


func _on_addcustom_pressed() -> void:
	var window = popUp_new_ratio.instantiate()
	window.created_new.connect(Created_New_Ratio)
	get_tree().root.add_child(window)
	

func Created_New_Ratio(resource_path: String) -> void:
	var new_ratio = load(resource_path)
	aspect_ratios.append(new_ratio)
	save_settings.aspect_options = aspect_ratios
	save_settings.aspect_selected = aspect_ratios.size() -1
	ResourceSaver.save(save_settings)
	Set_AspectRatios()


func _on_option_button_item_selected(index: int) -> void:
	var id = ($ScrollContainer/Itens/AspectRatios/OptionButton as OptionButton).get_item_id(index)
	save_settings.aspect_selected = id
	if id != 999:
		ratio = Vector2(aspect_ratios[id].ratio_width,aspect_ratios[id].ratio_height)
		if ($ScrollContainer/Itens/AspectRatios/keepOption as OptionButton).selected == 0:
			var w = ProjectSettings.get("display/window/size/viewport_width")
			_on_horizontal_text_submitted(str(w))
		else:
			var h = ProjectSettings.get("display/window/size/viewport_height")
			_on_vertical_text_submitted(str(h))
	ResourceSaver.save(save_settings)


func _on_remove_pressed() -> void:
	var confirmation_dialog = $ScrollContainer/Itens/AspectRatios/remove/ConfirmationDialog as ConfirmationDialog
	var aspect_name = aspect_ratios[save_settings.aspect_selected].name
	confirmation_dialog.dialog_text = "This will delete this aspect ratio (%s) forever!
	Are you sure you want to remove it from the list?" % aspect_name
	confirmation_dialog.show()


func _on_confirmation_dialog_confirmed() -> void:
	var path = aspect_ratios[save_settings.aspect_selected].resource_path
	aspect_ratios.remove_at(save_settings.aspect_selected)
	save_settings.aspect_options = aspect_ratios
	save_settings.aspect_selected = 999 # Custom
	ResourceSaver.save(save_settings)
	DirAccess.remove_absolute(path)
	Set_AspectRatios()
#endregion


#region Size options
func _on_number_text_changed(new_text: String) -> void:
	OnlyNumberString(new_text, $ScrollContainer/Itens/Sizes/HWidth/horizontal)


func _on_vertical_text_changed(new_text: String) -> void:
	OnlyNumberString(new_text, $ScrollContainer/Itens/Sizes/HHeight/vertical)


func OnlyNumberString(new_text: String, lineEdit: LineEdit) -> void:
	var num_text: String = "" if not new_text else str(new_text.to_int())
	lineEdit.text = num_text
	lineEdit.caret_column = num_text.length()


func SendErrorMessage(error_msg: String) -> void:
	($ScrollContainer/Itens/Sizes/Warning as Label).text = error_msg


func _on_horizontal_text_submitted(new_text: String) -> void:
	if save_settings.aspect_selected == 999:
		return
	
	var number_submitted := new_text.to_int()
	var width: int =  ratio.x
	var height: int =  ratio.y
	var rest: int = number_submitted % width
	var closest_number: int
	if ($ScrollContainer/Itens/Sizes/RoundUp as CheckButton).button_pressed and rest != 0:
		closest_number = number_submitted - rest + width
	else:
		closest_number = number_submitted - rest
	var multiplier: int = closest_number / width
	SetWidthandHeight(closest_number, height * multiplier)


func _on_vertical_text_submitted(new_text: String) -> void:
	if save_settings.aspect_selected == 999:
		return
	
	var number_submitted := new_text.to_int()
	var width: int =  ratio.x
	var height: int =  ratio.y
	var rest: int = number_submitted % height
	var closest_number: int
	if ($ScrollContainer/Itens/Sizes/RoundUp as CheckButton).button_pressed:
		closest_number = number_submitted - rest + height
	else:
		closest_number = number_submitted - rest
	var multiplier: int = closest_number / height
	SetWidthandHeight(width * multiplier, closest_number)


func SetWidthandHeight(width: int, height: int) -> void:
	$ScrollContainer/Itens/Sizes/HWidth/horizontal.text = str(width)
	$ScrollContainer/Itens/Sizes/HHeight/vertical.text = str(height)
	save_settings.screensize = Vector2i(width, height)
	ResourceSaver.save(save_settings)
	
	ProjectSettings.set("display/window/size/viewport_width", width)
	ProjectSettings.set("display/window/size/viewport_height", height)
	ProjectSettings.save()
	
	if width > DisplayServer.screen_get_size().x or height > DisplayServer.screen_get_size().y:
		var warn := "Warning: This is bigger than your monitor resolution:
			%sx%s" % [DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y]
		SendErrorMessage(warn)
	else:
		SendErrorMessage("")
#endregion
