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
	for child in get_children():		
		child.queue_free()		
	if track.type == TYPES.Bool:		
		control = CheckBox.new()	
		add_child(control)		
		control.pressed = key.value
	elif track.type in [TYPES.Float,TYPES.Str, TYPES.Vec2,TYPES.Vec3]:
		control = Label.new()	
		add_child(control)		
		control.text = str(key.value)
		hint_tooltip = control.text
	elif track.type == TYPES.Res:			
		control = Button.new()
		add_child(control)		
		#TO DO: implement resource picker
		#Is resource displayed as a str of filepath?	
	elif track.type == TYPES.Vec4:		
		control = ColorRect.new()
		add_child(control)	
		if key.valid:
			control.color = key.value
			control.rect_size = Vector2(40, 40)
			hint_tooltip = str(control.color)
	currentType = track.type		
	track.validateValueType(key.value)
	
func showSelector():
	var	valuePicker = valuePickerScene.instance()
	valuePicker.type = currentType	
	valuePicker.connect("tree_exited", self, "setValue", [lastKey])
	get_viewport().add_child(valuePicker)	
	valuePicker.popup()
