tool
extends Panel
class_name Track

#this enum is defined here AND in ExtraAnimation.gd. 
enum Types {
	Bool, Float, Vec2, Vec3, Vec4, Res
}
var type = Types.Float
var object
var property
var inputs

var objectPickerDialog = preload("res://ObjectPicker.tscn")
var propertyPickerDialog = preload("res://PropertyPicker.tscn")
var dialog
var canvas

#PLAYBACK
var lastKeyframe

##### TO DO: first keyframe should default to time 0, with a relative value 0...

func _init():	
	#rect_size = Vector2(1000, 20)	
	if !is_in_group("AnimationTracks"):
		add_to_group("AnimationTracks")

func frameChanged(position):
	#check to see if we've moved on to the next keyframe
	for i in get_child_count():
		var child = get_child(i)
		if !child.is_in_group("keyframe"):
			continue
		if child.time > position:
			var previousChild = get_child(i-1)
			if !previousChild.is_in_group("keyframe"):
				continue
			if !lastKeyframe == previousChild:			
				lastKeyframe = previousChild
				lastKeyframe.startingValue = get_parent().getPropertValue(self)
				break
			
func findNearestKeyframes(time) -> Array:
	for i in get_child_count():
		var child = get_child(i)
		if !child.is_in_group("keyframe"):
			continue
		if child.time > time:
			var previousChild = get_child(i-1)
			if !previousChild.is_in_group("keyframe"):
				continue
			return [get_child(i-1), get_child(i)]				
	var last = get_child(get_child_count()-1)
	return [last, last]
	
func select_from_context(what = "object"):
	if !canvas:
		canvas = CanvasLayer.new()
		canvas.layer = 20
	add_child(canvas)
	
	if what == "property":		
		dialog = propertyPickerDialog.instance()
		dialog.connect("tree_exiting", self, "prop_selected")
		dialog.context = aes.previewContext.instance().get_node(object)
	elif what == "object":
		dialog = objectPickerDialog.instance()
		dialog.connect("tree_exiting", self, "obj_selected")
		dialog.context = aes.previewContext
	canvas.add_child(dialog)
	dialog.set_anchors_and_margins_preset(Control.PRESET_WIDE)	
	dialog.popup()
	
func obj_selected():	
	#remove_child(canvas)
	if dialog.selectedObject:
		object = dialog.selectedObject
		var button = find_node("ObjectButton")
		button.text = object
		button.hint_tooltip = object		

func prop_selected():
	#remove_child(canvas)
	if dialog.selectedProperty:
		property = dialog.selectedProperty
		var button = find_node("PropertyButton")
		button.text = property
		button.hint_tooltip = property


func _get_property_list():
	var property_list = []
	property_list.append({
		"name": "type",
		"hint": PROPERTY_HINT_ENUM,
		"usage": PROPERTY_USAGE_DEFAULT,    	
		"type": TYPE_INT,
		"hint_string": Types

	})	
	
	return property_list
