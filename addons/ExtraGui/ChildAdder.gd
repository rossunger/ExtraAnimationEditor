extends Control
class_name ChildAdder, "add_icon.png"

export(String, FILE, "*.tscn") var who
		
var parent

func _ready():	
	who = load(who)	
	parent = get_parent()
	parent.connect("gui_input", self, "gui_input")
	parent.add_user_signal("created")
	parent.add_user_signal("removing")
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	rect_size = Vector2(0,0)
	
func gui_input(event):	
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed && Input.is_key_pressed(KEY_CONTROL):
		var child = who.instance()
		child.rect_position = event.position	
		parent.add_child(child)
		parent.emit_signal("created", child)		
