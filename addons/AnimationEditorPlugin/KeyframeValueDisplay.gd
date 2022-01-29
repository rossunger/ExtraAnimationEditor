tool
extends Control

var currentType = null
var valuePickerScene = preload("res://addons/AnimationEditorPlugin/ValuePicker.tscn")
var lastKey

func setValue(key):	
	lastKey = key
	hint_tooltip = ""
	var track = key.get_parent()
	
	var control
	if get_child_count() > 0:	
		control = get_child(0)
		if currentType != track.type:		
			get_child(0).queue_free()		
	if track.type == TYPES.Bool:
		if not is_instance_valid(control):
			control = CheckBox.new()	
			add_child(control)		
		control.pressed = bool(key.value)	
	elif track.type in [TYPES.Float,TYPES.Str, TYPES.Vec2,TYPES.Vec3]:
		if not is_instance_valid(control):
			control = Label.new()	
			add_child(control)		
		control.text = str(key.value)
		hint_tooltip = control.text
	elif track.type == TYPES.Res:			
		if not is_instance_valid(control):
			control = Button.new()
			add_child(control)		
			#Is resource displayed as a str of filepath?
		pass
	elif track.type == TYPES.Vec4:
		if not control is ColorRect:
			control = ColorRect.new()
			add_child(control)		
		control.color = key.value
		control.rect_size = Vector2(40, 40)
	currentType = track.type		
	
func showSelector():
	var	valuePicker = valuePickerScene.instance()
	valuePicker.type = currentType	
	valuePicker.connect("tree_exited", self, "setValue", [lastKey])
	get_viewport().add_child(valuePicker)	
	valuePicker.popup()
