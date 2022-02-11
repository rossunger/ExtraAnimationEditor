tool
extends Control
class_name Track

#RUNTIME VARS
export var type = TYPES.Float
export (String) var object #path to object from scene root
export (String) var property
#export (String) var subProperty = ""
var obj
var inputs
var lastKeyframe
var absoluteValueAtLastKeyframe
var absoluteValueAtNextKeyframe
var trackStartingValue
var trackOriginalStartingValue
var nextKeyframe
var nextKeyframeTime = 0

#EDITOR VARS
var dialog
var canvas
var KeyframeScene = preload("Keyframe.tscn")
var keyframesAreDragging = false

##### TO DO: first keyframe should default to time 0, with a relative value 0...

func _enter_tree():
	if !is_in_group("Tracks"):
		add_to_group("Tracks")

func _ready():	
	var hasStartingKey = false
	var hasEndingKey = false
	for child in get_children():
		if child.time == 0:
			hasStartingKey = true				
	if not hasStartingKey:
		addKeyframe(0)
		
func frameChanged(position = owner.position): # #TimelineEditor.animation.position):
	if Engine.editor_hint and not is_instance_valid(TimelineEditor.animation.currentScene):
		return
		
	#TO DO: implement a reset button that resets the trackStartingValue to original
	#if !trackOriginalStartingValue:		
	#	trackOriginalStartingValue = obj[property]

	var lastChildIndex = get_child_count()-1

	#If only one keyframe, then set the value and stop.
	if owner.duration == 0:		
		lastKeyframe = get_child(0)
		nextKeyframe = get_child(0)
		if !lastKeyframe.relative:
			applyKeyframeValues(0)		
		owner.stop()
		return
		
	#Object is a NodePath. When playing, make sure we've got object and put it in Obj
	if not is_instance_valid(obj):
		if Engine.editor_hint:
			obj = TimelineEditor.animation.currentScene.get_node(object)								
		else:	
			if owner.owner.has_node(object):
				obj = owner.owner.get_node(object)				
			else:
				print("error: ", name, " can't find it's object: ", object, " doesnt exist in relation to this animation's owner")
			pass
	
	#Figure out if we're playing forwards or backwards
	var directionModifier
	if owner.speed < 0:
		directionModifier = -1
	else:
		directionModifier = 1
	
	#Record the starting value at 0 for use with "relative" keyframes	
	var shouldUpdateStartingValue
	if directionModifier == -1:
		shouldUpdateStartingValue = position == owner.duration	
	else:
		shouldUpdateStartingValue = position == 0
	if !validateValueType(trackStartingValue):
		shouldUpdateStartingValue = true
	
	if shouldUpdateStartingValue:		
		trackStartingValue = getObjPropValue() #obj[property]

	
	#Check if we've reached the next keyframe in the direction of playback
	var needToUpdateKeyframes
	if directionModifier < 0:
		needToUpdateKeyframes = shouldUpdateStartingValue or nextKeyframeTime >= position
	else:
		needToUpdateKeyframes = shouldUpdateStartingValue or nextKeyframeTime <= position		
		
	#if we've moved to the next keyframe (+ other safety check)
	if needToUpdateKeyframes or not is_instance_valid(nextKeyframe) or not is_instance_valid(lastKeyframe):				
		#let's assume there's only 2 keys to start with
		if directionModifier < 0:
			lastKeyframe = get_child(lastChildIndex)
			nextKeyframe = get_child(0)
		else:
			lastKeyframe = get_child(0)
			nextKeyframe = get_child(lastChildIndex)
		nextKeyframeTime = nextKeyframe.time		
		#if there's more than two keyframes, then it's more complicated...
		if lastChildIndex !=1:							
			#Let's go over each key (which should be siblings in chronological order)
			for i in lastChildIndex+1:					
				var key				
				var foundTheNextKey
				#if the playhead is behind the key, continue 			
				if owner.speed < 0:
					key = get_child(lastChildIndex - i)
					if key.time > position: # and key.get_index() != 0:
						continue
				else:
					key = get_child(i)
					if key.time < position: # and key.get_index() != lastChildIndex:					
						continue	
			
				var previousChild
				var prevChildIndex = key.get_index() - directionModifier
				#print(prevChildIndex)
				if prevChildIndex >= 0 and prevChildIndex <= lastChildIndex:
					previousChild = get_child(prevChildIndex)						
				else:
					previousChild = key						
				lastKeyframe = previousChild
				nextKeyframe = key
				nextKeyframeTime = key.time		
								
				#print("LK: ", lastKeyframe.name, " | NK: ", nextKeyframe.name)
				break					
			
		if not is_instance_valid(lastKeyframe) or not is_instance_valid(nextKeyframe):
			print("Error: lastkeyframe or nextkeyframe doesnt exist when it should")
			return
			
		absoluteValueAtLastKeyframe = lastKeyframe.value
		absoluteValueAtNextKeyframe = nextKeyframe.value
		if lastKeyframe.value is String and lastKeyframe.value.find("var") != -1:			
			if !owner.variables.has(nextKeyframe.value):
				print("ERROR: variable doesn't exist")
				print(owner.variables.keys())
				absoluteValueAtLastKeyframe = nextKeyframe.value
				return
			var varVar = owner.variables[lastKeyframe.value]
			var varObject = owner.get_node(varVar["object"])
			var varValue = varObject[varVar["var"]]
			absoluteValueAtLastKeyframe = varValue
			print("LK: ", absoluteValueAtLastKeyframe)
		
		if nextKeyframe.value is String and nextKeyframe.value.find("var") != -1:								
			if !owner.variables.has(nextKeyframe.value):
				print("ERROR: variable doesn't exist")
				print(owner.variables.keys())
				absoluteValueAtNextKeyframe = lastKeyframe.value
				return				
			var varVar = owner.variables[nextKeyframe.value]
			var varObject = owner.get_node(varVar["object"])
			var varValue = varObject[varVar["var"]]
			absoluteValueAtNextKeyframe = varValue
			print("VarVar: " , absoluteValueAtLastKeyframe)
			
		if type in [TYPES.Bool, TYPES.Float, TYPES.Vec2, TYPES.Vec3, TYPES.Vec4] and nextKeyframe.relative:			
			#init delta as the correct type
			var delta
			if type == TYPES.Bool:
				delta = false
			elif type == TYPES.Float:
				delta = 0
			elif type == TYPES.Vec2:
				delta = Vector2(0,0)
			elif type == TYPES.Vec3:
				delta = Vector3(0,0,0)
			elif type == TYPES.Vec4:
				delta = Color(1,1,1,1)
			var k = lastKeyframe
			while k.relative:		
				var reachedEnd
				if directionModifier == 1:	
					reachedEnd = k.get_index() == 0
				else:
					reachedEnd = k.get_index() == lastChildIndex
				if reachedEnd:
					if type == TYPES.Bool:
						delta = !trackStartingValue
					else:
						delta += trackStartingValue
					break
				if type == TYPES.Bool:
					delta = !k.value
				else:
					delta += k.value
				k = get_child(k.get_index() - directionModifier)
				
			if type == TYPES.Bool and delta:
				absoluteValueAtLastKeyframe = !k.value 
				absoluteValueAtNextKeyframe = delta
			else:								
				absoluteValueAtLastKeyframe = k.value + delta
				absoluteValueAtNextKeyframe = k.value + delta + nextKeyframe.value
	
	#print(owner.position, " : ", owner.position - lastKeyframe.time, nextKeyframe.time - lastKeyframe.time)
	#print("Relative. TSV: " , trackStartingValue ,". AVALK: ",absoluteValueAtLastKeyframe, ". AVANK: ", absoluteValueAtNextKeyframe )
	#print("LK: ", lastKeyframe.name, " | NK: ", nextKeyframe.name)
	var lerpWeight
	if nextKeyframe.time - lastKeyframe.time == 0:		
		print("ERROR: two keyframes at the same time position")	
		return
	if owner.position - lastKeyframe.time == 0:
		lerpWeight = 0		
	else:
		lerpWeight = clamp( (owner.position - lastKeyframe.time) / (nextKeyframe.time - lastKeyframe.time), 0,1)		
	applyKeyframeValues(lerpWeight)	
	
func applyKeyframeValues(lerpWeight):
	#SET THE VALUES
	if type == TYPES.Bool:
		if lastKeyframe.value is bool:
			if lastKeyframe.relative and absoluteValueAtLastKeyframe == true:				
				obj[property] = !obj[property]
				return
			else:	
				#setObjPropValue(absoluteValueAtLastKeyframe.value)
				obj[property] = absoluteValueAtLastKeyframe
				return
		else:
			print("last key should be type Bool, but it is: ", lastKeyframe.value, " : type: ", typeof(lastKeyframe.value))			
	
	if type == TYPES.Float:
		if absoluteValueAtLastKeyframe is float or absoluteValueAtLastKeyframe is int:			
			setObjPropValue(lerp(absoluteValueAtLastKeyframe, absoluteValueAtNextKeyframe, lerpWeight))
			#obj[property] = lerp(absoluteValueAtLastKeyframe, absoluteValueAtNextKeyframe, lerpWeight)
			
		else:
			print("last key should be type Float, but it is: ", lastKeyframe.value, " : type: ", typeof(lastKeyframe.value))					
	if type == TYPES.Vec2:
		if absoluteValueAtLastKeyframe is Vector2:			
			#setObjPropValue(absoluteValueAtLastKeyframe.linear_interpolate( absoluteValueAtNextKeyframe, lerpWeight))
			obj[property] = absoluteValueAtLastKeyframe.linear_interpolate( absoluteValueAtNextKeyframe, lerpWeight)			
		else:
			print("last key should be type Vec2, but it is: ", lastKeyframe.value, " : type: ",  typeof(lastKeyframe.value))	
	if type == TYPES.Vec3:
		if absoluteValueAtLastKeyframe is Vector3:						
			#setObjPropValue(absoluteValueAtLastKeyframe.linear_interpolate( absoluteValueAtNextKeyframe, lerpWeight))
			obj[property] = absoluteValueAtLastKeyframe.linear_interpolate( absoluteValueAtNextKeyframe, lerpWeight)						
		else:
			print("last key should be type Vec3, but it is: ", lastKeyframe.value, " : type: ",  typeof(lastKeyframe.value))	

	if type == TYPES.Vec4:
		if absoluteValueAtLastKeyframe is Color:						
			#setObjPropValue(absoluteValueAtLastKeyframe.linear_interpolate( absoluteValueAtNextKeyframe, lerpWeight))
			obj[property] = absoluteValueAtLastKeyframe.linear_interpolate( absoluteValueAtNextKeyframe, lerpWeight)						
		else:
			print("last key should be type Vec4, but it is: ", lastKeyframe.value, " : type: ",  typeof(lastKeyframe.value))	

	if type == TYPES.Str:
		if lastKeyframe.value as String:						
			if property.find("#Func") == -1:
				obj[property] = absoluteValueAtLastKeyframe 			
			else:				
				var params = absoluteValueAtLastKeyframe.split(",")
				
				if params.size() > 1:
					obj.call(params[1], params[2])
				else:
					print("calling func")
					obj.call(params[1])
		else:
			print("last key should be type Str, but it is: ", lastKeyframe.value, " : type: ",  typeof(lastKeyframe.value))	

	#TO DO:
	#implement str, and res... also reference to an object's param?

func findNearestKeyframes(time) -> Array:
	for i in get_child_count():
		var child = get_child(i)
		if child.time > time and i > 0:
			var previousChild = get_child(i-1)
			if !previousChild.is_in_group("keyframe"):
				continue
			return [get_child(i-1), get_child(i)]				
	var last = get_child( max(0, get_child_count()-1))
	return [last, last]

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
	
func _input(event):
	if event is InputEventMouse and event.button_mask == 1:			
		if get_global_rect().has_point(event.position):			
			TimelineEditor.focusedTrack = self			
			if event is InputEventMouseButton and event.doubleclick:				
				if event.control:
					#SELECT ALL:
					get_tree().call_group("SelectionController", "interrupt")
					for key in get_children():
						key.doSelect()					
					accept_event()
				else:
					var x = (event.position.x-rect_global_position.x) / TimelineEditor.zoom.x -  TimelineEditor.scroll.x					
					#print(event.position.x-rect_global_position.x)
					addKeyframe(max(0, x))					
			
			#for child in k.get_children():
			#	child.owner = owner

func _gui_input(event):
	if event is InputEventMouseButton:		
		if event.button_index == 1 and event.is_pressed():			
			#owner.setTime(event.position.x / TimelineEditor.zoom.x) #.zoom.x ) #TODO: fix magic number...
			owner.emit_signal("frameChanged")		

func addKeyframe(time, value=null, relative = false, curve= null):		
	var k = KeyframeScene.instance()				
	if value == null:
		setDefaultKeyValue(k)
	else:
		k.value = value	
	k.relative = relative	
	k.time = time	
	if curve:
		k.curve = curve
	add_child(k)
	k.owner = owner #get_editor_interface().get_edited_scene_root()	
	k.call_deferred("setXFromTime")
		
	validateKeyframeOrder()
	TimelineEditor.addUndo(TimelineEditor.undoTypes.create, k)
	return k

func setDefaultKeyValue(k):
	if type == TYPES.Bool:
		k.value = false
		k.relative = true
	if type == TYPES.Float:
		k.value = 0
		k.relative = true
	if type == TYPES.Vec2:		
		k.value = Vector2(0,0)
		k.relative = true
	if type == TYPES.Vec3:
		k.value = Vector3(0,0,0)
		k.relative = true
	if type == TYPES.Vec4:
		k.value = Color(0,0,0,0)
		k.relative = true
	if type == TYPES.Str:
		k.value = ""
		
func validateValueType(value):	
	if value is String and value.find("#Var") != -1:
		value = owner.variables[value]
		
	if type == TYPES.Bool:
		if typeof(value) == TYPE_BOOL:
			return true
		else:
			return false
	if type == TYPES.Float:
		if typeof(value) == TYPE_REAL or typeof(value) == TYPE_INT:
			return true
		else:			
			return false
	if type == TYPES.Vec2:
		if typeof(value) == TYPE_VECTOR2:
			return true
		else:
			return false
	if type == TYPES.Vec3:
		if typeof(value) == TYPE_VECTOR3:
			return true
		else:
			return false
	if type == TYPES.Vec4:
		if typeof(value) == TYPE_COLOR:
			return true
		else:
			return false
	if type == TYPES.Str:
		if typeof(value) == TYPE_STRING:
			return true
		else:
			return false

#This function makes sure that keyframes are in
#chronological order, and that no 2 keys overlap
func validateKeyframeOrder():	
	var lastKeyIndex = 0	
	var keys = get_children()
	for i in keys.size():
		if i == lastKeyIndex:
			continue
		var j = i
		while j >0 and keys[i].time <= keys[j-1].time:		
			if keys[i].time == keys[j-1].time:	
				keys[j-1].time += TimelineEditor.snap
			j -= 1
		move_child(keys[i], j)		
		
	#UNIT TESTING this function:	
	#var children = get_children()
	#for i in get_child_count()-2:	#
	#	if children(i+1).time <= children(i).time:
	#		return false
	#return true	

func reorderKeyByTime(key):
	for child in get_children():
		if child == key:
			continue
		if child.time > key.time:
			move_child(key, child.get_index())

func getKeyframeAtTime(time, keyframeToIgnore = null):
	for child in get_children():
		if child.time == time and child != keyframeToIgnore:
			return child

func getObjPropValue():
	var props = property.split(".")
	var size = props.size()
	if size==1:
		return obj[props[0]]
	elif size==2:
		return obj[props[0]][props[1]]
			
func setObjPropValue(value):
	var props = property.split(".")
	var size = props.size()
	if size==1:
		obj[props[0]] = value
	elif size==2:
		obj[props[0]][props[1]] = value
		
func updateZoomY():
	rect_min_size.y = 60 * TimelineEditor.zoom.y
