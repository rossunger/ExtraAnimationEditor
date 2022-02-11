tool
extends PopupDialog

var type
var control
var keys #selected keys
onready var parent = $Modal

func _exit_tree():
	updateKeyframeValues()
	queue_free()

func updateKeyframeValues():	
	var prop
	for key in keys:
		if type == TYPES.Str:
			key.value = control.text
		elif type == TYPES.Float:
			key.value = str2var(control.text)
		elif type == TYPES.Vec2:
			key.value = str2var("Vector2( " + control.text + " )")				
		elif type == TYPES.Vec3:
			key.value = str2var("Vector3( " + control.text + " )")
		elif type == TYPES.Vec4:
			key.value = control.color			
			
	
func _ready():	
	keys = get_tree().get_nodes_in_group("selected")		
	type = keys.back().get_parent().type
	if type in [TYPES.Float, TYPES.Str, TYPES.Vec2,TYPES.Vec3]:
		control = LineEdit.new()
		control.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		parent.margin_left -= 20
		parent.margin_top -= 20
		parent.margin_right += 20
		parent.margin_bottom += 20
		control.align = LineEdit.ALIGN_CENTER
		control.text = str(keys.back().value)
		control.connect("text_entered", self, "validateText")
	elif type == TYPES.Res:			
		#TO DO
		pass
	elif type == TYPES.Vec4:
		parent.margin_left -= 200
		parent.margin_top -= 400		
		control = ColorPicker.new()
		if keys.back().value is Color:
			control.color = keys.back().value
		else:
			control.color = Color(1,1,1,1)
		control.size_flags_vertical = SIZE_EXPAND_FILL		
	if is_instance_valid(control):
		parent.add_child(control)
		parent.rect_size = control.rect_size + Vector2(80, 80)
		control.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	else:
		print("error: no control. Type is: ", type)

func validateText(text):
	if type == TYPES.Float:
		var regex = RegEx.new()
		regex.compile("[0-9]*\\.?[0-9]+")
		var result = regex.search(text)
		if result:			
			queue_free()
	elif type == TYPES.Vec2:
		if text.count(",") == 1:
			queue_free()
		else:
			text = ""
	elif type == TYPES.Vec3:
		if text.count(",") == 2:
			queue_free()
	else:
		queue_free()
	


func _on_Dimmer_pressed():
	queue_free()
