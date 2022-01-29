tool
extends Control
class_name ExtraAnimation

var debug = true

#RUNTIME SIGNALS
signal frameChanged
signal stop
signal play

##RUNTIME EXPORT VARS
var speed = 1
var autoDuration = true 
var playing = false
var duration = 1 
var looping = false

#EDITING EXPORT VARS
export (String, FILE, "*.tscn, PackedScene") var defaultPreviewScene = ""
var currentScene

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
	mouse_filter = Control.MOUSE_FILTER_PASS
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
	if !timeline.has_node("Playhead"):
		var playhead = Playhead.new()
		timeline.add_child(playhead)
		playhead.owner = self
		
	if !timeline.has_node("SelectionController"):
		var sc = SelectionController.new()
		sc.name = "SelectionController"
		timeline.add_child(sc)	
		sc.owner = self
		
	trackMeta = get_node("TrackMeta")
		
	for child in timeline.tracks.get_children():		
		if child.get_script().get_path().find("Track.gd") != -1:		
			if !is_connected("frameChanged", child, "frameChanged"):
				connect("frameChanged", child, "frameChanged")	
	
func togglePlay():		
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
	if start == duration:
		position = 0
	emit_signal("play")

func stop():
	playing = false
	emit_signal("stop")
	
func _physics_process(delta):	
	if !playing: 
		return
	position+=delta*speed
	if !looping:
		if speed > 0:
			position = min(position, duration)
			if position == duration:
				stop()
		else:
			position = max(position, 0)
	elif speed > 0:
		if position+ delta * speed >= duration:
			position = 0
	else:
		if position+ delta * speed <= 0:
			position = duration
	applyValues()

func applyValues():
	if !is_instance_valid(timeline) or !is_instance_valid(timeline.tracks):
		return
	emit_signal("frameChanged")
	return
	
	for track in timeline.tracks.get_children():	
		if track.get_script().get_path().find("Track.gd") == -1:		
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
	if !is_instance_valid(timeline) or !is_instance_valid(timeline.tracks):			
		return				
	duration = 0		
	for track in timeline.tracks.get_children():
		if track.get_child_count() == 0: 
			continue			
		duration = max(duration, track.get_child(track.get_child_count()-1).time)						
func play_backwards(anim):
	play(-1, 1)

func _set(prop, value):
	#RUNTIME VARS	
	if prop == "Duration":
		duration = value		
		return true
	if prop == "AutoDuration":		
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
		if track.get_script().get_path().find("Track.gd") != -1:		
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
	var t = TrackScene.instance()	
	var tm = TrackMetaScene.instance()
	timeline.tracks.add_child(t)	
	trackMeta.add_child(tm)	
	t.owner = self
	tm.owner = self
	tm.track = get_path_to(t)
	

func removeTrack(meta):
	get_node(meta.track).queue_free()
	meta.queue_free()

func setTime(newTime):
	position = newTime
