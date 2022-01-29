tool
extends Control
class_name Track

#RUNTIME VARS
export var type = TYPES.Float
export (String) var object #path to object from scene root
export (String) var property
var obj
var inputs
var lastKeyframe
var absoluteValueAtLastKeyframe
var absoluteValueAtNextKeyframe
var trackStartingValue
var nextKeyframe
var nextKeyframeTime = 0

#EDITOR VARS
var objectPickerDialog = preload("ObjectPicker.tscn")
var propertyPickerDialog = preload("PropertyPicker.tscn")
var dialog
var canvas
var KeyframeScene = preload("Keyframe.tscn")
var keyframesAreDragging = false

##### TO DO: first keyframe should default to time 0, with a relative value 0...

func _enter_tree():
	if !is_in_group("draggable"):
		add_to_group("draggable")

func reorderKeyByTime(key):
	for child in get_children():
		if child == key:
			continue
		if child.time < key.time:
			key.move_child(child.get_index())

func frameChanged(position = TimelineEditor.animation.position):
	if not is_instance_valid(TimelineEditor.animation.currentScene):
		return

	#Object is a NodePath. When playing, make sure we've got object and put it in Obj
	if not is_instance_valid(obj):
		if Engine.editor_hint:
			obj = TimelineEditor.animation.currentScene.get_node(object)					
			print("setting obj: ", obj.get_path())
		else:	
			print("not editor?")						
			#implement runtime animation... who is the root?
			pass
	
	var directionModifier
	if owner.speed < 0:
		directionModifier = -1
	else:
		directionModifier = 1
	#Record the starting value at 0 for use with "relative" keyframes

	var shouldUpdateStartingValue
	if directionModifier == -1:
		shouldUpdateStartingValue = position > owner.duration - 0.1
	else:
		shouldUpdateStartingValue = position < 0.1
	if shouldUpdateStartingValue:
		print("updating startvalue: ", obj[property])
		trackStartingValue = obj[property]

	var needToUpdateKeyframes
	#Check if playing forwards or backwards
	if owner.speed < 0:
		needToUpdateKeyframes = nextKeyframeTime > position
	else:
		needToUpdateKeyframes = nextKeyframeTime < position

	#if the keyframe has changed...
	if needToUpdateKeyframes:
		for key in get_children():		
			if !key.is_in_group("Keyframe"):
				continue
			var foundTheNextKey 			
			if owner.speed < 0:
				foundTheNextKey = key.time < position and key.get_index() < (get_child_count()-1)
			else:
				foundTheNextKey = key.time > position and key.get_index() > 0		
			
			if foundTheNextKey:				
				var previousChild = get_child(key.get_index() - directionModifier)
				if !previousChild.is_in_group("keyframe"):
					continue
				if !lastKeyframe == previousChild:			
					lastKeyframe = previousChild
					nextKeyframe = key
					nextKeyframeTime = key.time
					absoluteValueAtLastKeyframe = lastKeyframe.value
					absoluteValueAtNextKeyframe = nextKeyframe.value
					break
	
		if type in [TYPES.Bool, TYPES.Float, TYPES.Vec2, TYPES.Vec3, TYPES.Vec4] and nextKeyframe.relative:
			print("Relative. TSV: " , trackStartingValue ,". AVALK: ",absoluteValueAtLastKeyframe, ". AVANK: ", absoluteValueAtNextKeyframe )
			var dif
			if type == TYPES.Bool:
				dif = false
			if type == TYPES.float:
				dif = 0
			if type == TYPES.Vec2:
				dif = Vector2(0,0)
			if type == TYPES.Vec3:
				dif = Vector3(0,0,0)
			if type == TYPES.Vec4:
				dif = Color(1,1,1,1)
			var k = lastKeyframe
			while k.relative:		
				var reachedEnd
				if directionModifier == 1:	
					reachedEnd = k.get_index() == 0
				else:
					reachedEnd = k.get_index() == get_child_count()-1
				if reachedEnd:
					if type == TYPES.Bool:
						dif = !trackStartingValue
					else:
						dif += trackStartingValue
					break
				if type == TYPES.Bool:
					dif = !k.value
				else:
					dif += k.value
				k = get_child(k.get_index() - directionModifier)
				
			if type == TYPES.Bool and dif:
				absoluteValueAtLastKeyframe = !k.value 
				absoluteValueAtNextKeyframe = dif 
			else:
				absoluteValueAtLastKeyframe = k.value + dif
				absoluteValueAtNextKeyframe = dif 
		
	#SET THE VALUES
	if type == TYPES.Bool:
		if lastKeyframe.value is bool:
			if lastKeyframe.relative and absoluteValueAtLastKeyframe == true:
				obj[property] = !obj[property]
				return
			else:				
				obj[property] = absoluteValueAtLastKeyframe.value
				return
		else:
			print("last key should be type Bool, but it is: ", lastKeyframe.value, " : type: ", typeof(lastKeyframe.value))			
					
	
	var lerpWeight = clamp( (owner.position - lastKeyframe.time) / (nextKeyframe.time - lastKeyframe.time), 0,1)	
	
	if type == TYPES.Float:
		if lastKeyframe.value is float:			
			obj[property] = lerp(absoluteValueAtLastKeyframe, absoluteValueAtNextKeyframe, lerpWeight)
			
		else:
			print("last key should be type Float, but it is: ", lastKeyframe.value, " : type: ", typeof(lastKeyframe.value))					
	if type == TYPES.Vec2:
		if lastKeyframe.value is Vector2:
			obj[property] = absoluteValueAtLastKeyframe.linear_interpolate( absoluteValueAtNextKeyframe, lerpWeight)			
		else:
			print("last key should be type Vec2, but it is: ", lastKeyframe.value, " : type: ",  typeof(lastKeyframe.value))	
			
func findNearestKeyframes(time) -> Array:
	for i in get_child_count():
		var child = get_child(i)
		if !child.is_in_group("keyframe"):
			continue
		if child.time > time and i > 0:
			var previousChild = get_child(i-1)
			if !previousChild.is_in_group("keyframe"):
				continue
			return [get_child(i-1), get_child(i)]				
	var last = get_child( max(0, get_child_count()-1))
	return [last, last]
	
func select_from_context(what = "object"):
	if !canvas:
		canvas = CanvasLayer.new()
		canvas.layer = 20
	owner.add_child(canvas)
	
	if what == "property":		
		dialog = propertyPickerDialog.instance()
		dialog.connect("tree_exiting", self, "prop_selected")
		#dialog.context = aes.previewContext.instance().get_node(object)
	elif what == "object":
		dialog = objectPickerDialog.instance()
		dialog.connect("tree_exiting", self, "obj_selected")
		#dialog.context = aes.previewContext
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
		"hint_string": TYPES

	})		
	
	return property_list

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:				
			if event.control:
				#SELECT ALL:
				get_tree().call_group("SelectionController", "interrupt")
				for key in get_children():
					key.get_node("Selectable").doSelect()	
				print("track stealing doubleclick")				
				accept_event()
				return
								
			var k = KeyframeScene.instance()
			k.rect_position.x = event.position.x
			add_child(k)	
			k.owner = owner #get_editor_interface().get_edited_scene_root()	
			#for child in k.get_children():
			#	child.owner = owner
		elif event.button_index == 1 and event.is_pressed():			
			#owner.setTime(event.position.x / TimelineEditor.zoom.x) #.zoom.x ) #TODO: fix magic number...
			owner.applyValues()
		elif keyframesAreDragging and event.button_index == 1 and !event.is_pressed():			
			get_tree().call_group("selected", "reparent", self)
	#if event is InputEventMouseMotion:	
		#print("name is dragging: ", keyframesAreDragging)
		#if keyframesAreDragging:
		#	get_tree().call_group("selected", "reparent", self)
		
func startMove():
	keyframesAreDragging = true
	#print("starting drag for ", name)

func endMove():	
	keyframesAreDragging = false
	#print("end drag for ", name)
