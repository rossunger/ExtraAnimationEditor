tool
extends Control
class_name Selectable, "select_icon.png"

# This component makes it's parent selectable 
var parent
var selected = false

func _enter_tree():
	if Engine.editor_hint:
		_ready()
		
func _ready():	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("selectable", true)	
	if !getParent().is_connected("resized", self, "resize"):
		getParent().connect("resized", self, "resize")
	resize()

#resize this component to be the size of it's parent
func resize():	
	rect_size = getParent().rect_size
	
func select_one(who):
	if getParent() == who:
		doSelect()
	else:
		deselect()
	
func drag_select(box: Rect2):	
	if !is_visible_in_tree():
		return
	var r = Rect2(getParent().rect_global_position, getParent().rect_size)	
	if box.intersects(r) && !r.encloses(box):				
		doSelect()


func doSelect():
	getParent().add_to_group("selected")
	selected = true
	TimelineEditor.grab_focus()
	TimelineEditor.selectionChanged(parent)
	update()

func deselect():		
	selected = false	
	if getParent().is_in_group("selected"):
		getParent().remove_from_group("selected")
	if get_tree().get_nodes_in_group("selected").size() == 0:
		TimelineEditor.selectionChanged(null)
	update()

func _draw():
	if selected:
		var sb = StyleBoxFlat.new()
		sb.border_color = Color.cornflower
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.draw_center = false
		draw_style_box(sb, Rect2(rect_position, rect_size))
		
func getParent():
	if !is_instance_valid(parent):
		parent = get_parent()
	return parent
	
