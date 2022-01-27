tool
extends Control
class_name ExtraAnimation

var debug = true

#this enum is defined here AND in track.gd
enum TYPES {
	Bool, Float, Res, Str, Vec2, Vec3, Vec4, 
}

#RUNTIME SIGNALS
signal frameChanged


##RUNTIME EXPORT VARS
var speed = 1
var autoDuration = true 
var playing = false
var duration = 1 
var looping = false

#EDITING EXPORT VARS
export (String, FILE, "*.tscn, PackedScene") var defaultPreviewScene = ""

#INTERNAL VARS
var position:float = 0
var context
var trackObjects = {}
var trackProperties = {}
var lastKeyframe
var timeline 
var trackMeta

#INTERNAL EDITOR VARS
var TrackScene = preload("Track.tscn")
var TrackMetaScene = preload("TrackMeta.tscn")
func _init():
	pass
	
func _enter_tree():	
	pass
	#if there's no context, then we're in runtime, so hide the interface
	if !debug or !Engine.editor_hint:
		hide()
	else:				
		if not is_in_group("animations"):
			add_to_group("animations")

	
func _ready():				
	if !Engine.editor_hint and !debug:
		hide()		
		
	timeline = get_node("Timeline")
	trackMeta = get_node("TrackMeta")
		
	for child in timeline.get_children():		
		if child is Track:
			if !is_connected("frameChanged", child, "frameChanged"):
				connect("frameChanged", child, "frameChanged")	
	
func togglePlay():
	print("toggling play")
	if playing:
		stop()
	else:
		if autoDuration:
			setDurationToLatestKeyframe()
		play()
		
func play(playSpeed=speed, start=position):
	playing = true
	speed = playSpeed
	position = start

func stop():
	playing = false
	
func _physics_process(delta):
	if !playing: 
		return
	position+=delta*speed
	if !looping:
		position = min(position, duration)
	elif position+ delta * speed >= duration:
		position = 0
		
	applyValues()

func applyValues():
	if !is_instance_valid(timeline):
		return
	emit_signal("frameChanged")
	for track in timeline.get_children():	
		if !track is Track:
			continue
		if getTrackObject(track) and getPropertyValue(track):			
	
			var keys = track.findNearestKeyframes(position)
					
			if [TYPES.Bool, TYPES.Res].has(track.type):			
				if position >= keys[1].time:				
					setPropertyValue(track, keys[1].value)			
				else:
					setPropertyValue(track, keys[0].value)			
			else:		
				var weight = keys[0].curve.interpolate( (position - keys[0].time) / (keys[1].time - keys[0].time) )			
				var value			
				if keys[0].absolute:
					if keys[1].absolute:					
						value = lerp(keys[0].value, keys[1].value, weight)
					else:
						value = lerp(keys[0].value, keys[0].value + keys[1].value, weight)
				else:
					if keys[1].absolute:
						value = lerp(keys[0].startingValue, keys[0].value, weight)
					else:
						value = lerp(keys[0].startingValue, keys[0].value + keys[1].value, weight)				
				setPropertyValue(track, value)

func getTrackObject(track):
	if !trackObjects.has(track.name):
		return
	if has_node(trackObjects[track.name]):
		return get_node(trackObjects[track.name])

func setPropertyValue(track, value):
	#object.rect_position.x	
	if trackProperties[track.name].find(".") == -1:
		getTrackObject(track)[trackProperties[track.name]] = value
	else:
		var p = trackProperties[track.name].split(".")
		if p[1] == "x" or p[1] == "r":
			getTrackObject(track)[p[0]].x = value
		elif p[1] == "y" or p[1] == "g":
			getTrackObject(track)[p[0]].y = value
		elif p[1] == "z" or p[1] == "b":
			getTrackObject(track)[p[0]].z = value
		elif p[1] == "a" or p[1] == "a":
			getTrackObject(track)[p[0]].x = value
	
func getPropertyValue(track):	
	#this function let's you get properties of properties:
	#e.g. the x of rect_position... 
	#usage: use a . as in "propertyA.propertyB.propertyC"	
	var p = trackProperties[track.name].split(".")
	var value = getTrackObject(track)
	for a in p:
		value = value[a]
	return value
			
func setDurationToLatestKeyframe():
	if !is_instance_valid(timeline):
		print("no timeline")
		return						
	for child in timeline.get_children():		
		if child is Track:
			duration = max(duration, child.get_child(child.get_child_count()-1).time)			
			print(duration)
func play_backwards(anim):
	play(-1, 1)

func _set(prop, value):
	#RUNTIME VARS	
	if prop == "Duration":
		duration = value		
		return true
	if prop == "AutoDuration":
		print("setting AutoDuration")
		autoDuration = value
		if autoDuration:		
			setDurationToLatestKeyframe()
		property_list_changed_notify()
		return true		
	
	if prop.find("Tracks/") == -1:
		return
		
	for track in get_children():
		if prop == "Tracks/" + track.name + "/obj":
			trackObjects[track.name] =  value
		if prop == "Tracks/" + track.name + "/prop":
			trackProperties[track.name] = value			
	
	
func _get(prop):	
	#RUNTIME VARS
	if prop=="Duration":
		return duration			
	if prop == "AutoDuration":
		return autoDuration
		
	if prop.find("Tracks/") == -1:
		return
	for track in get_children():
		if prop == track.name + "/obj":			
			if trackObjects.has(track.name):
				return trackObjects[track.name]
		if prop == track.name + "/prop":											
			if trackProperties.has(track.name):
				return trackProperties[track.name]		
	return
	
func _get_property_list():	# overridden function
	var property_list = []	
	property_list.append({
		"name": "speed",				    
		"type": TYPE_REAL,				
	})
	property_list.append({
		"name": "AutoDuration",				
		"type": TYPE_BOOL,				
	})		
	var dur = {
		"name": "Duration",
		"hint": PROPERTY_HINT_RANGE,
		"usage": PROPERTY_USAGE_NOEDITOR,    	
		"type": TYPE_REAL,			
		"hint_string": "0,60,1,or_greater"
	}	
	if !autoDuration:
		dur.usage = PROPERTY_USAGE_DEFAULT
	property_list.append(dur)
	
	property_list.append({
		"name": "looping",				
		"type": TYPE_BOOL,	
		"usage": PROPERTY_USAGE_DEFAULT			
	})
	
	for track in get_children():
		if track is Track:			
			property_list.append({
				"name": "Tracks/" + track.name +"/obj",
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,    	
				"type": TYPE_NODE_PATH,
				"hint_string": ""		
			})
			property_list.append({
				"name": "Tracks/" + track.name +"/prop",
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,    	
				"type": TYPE_STRING,
				"hint_string": ""		
			})
			property_list.append({
				"name": "trackObjects",
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_STORAGE,    	
				"type": TYPE_DICTIONARY,			
			})
			property_list.append({
				"name": "trackProperties",
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_STORAGE,    	
				"type": TYPE_DICTIONARY,			
			})
	return property_list


func addTrack():
	var ts = TrackScene.instance()	
	var tm = TrackMetaScene.instance()
	$Timeline.add_child(ts)	
	$TrackMeta.add_child(tm)		
	ts.owner = self
	tm.owner = self

func setTime(newTime):
	position = newTime