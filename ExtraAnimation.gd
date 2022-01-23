tool
extends Control
class_name ExtraAnimation

#this enum is defined here AND in track.gd
enum TYPES {
	Bool, Float, Vec2, Vec3, Vec4, Res
}

signal frameChanged

var playing = false
export var speed = 1
var position:float = 0
var duration = 0
var root
var tracks
var trackObjects = {}
var trackProperties = {}
var keyframes = []
export var looping = false
var lastKeyframe
var asvfd: Quat
func _ready():		
	if get_parent().name != "AnimationEditor":
		hide()
	for child in get_children():		
		connect("frameChanged", child, "frameChanged")	
		duration = child.get_child(child.get_child_count()-1).time
	
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
	
	aes.emit_signal("frameChanged", position)
	
	for track in get_children():						
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
			

func play_backwards(anim):
	play(-1, 1)

#This is where we parse the json file for data, but not for nodes
func loadAnimation(path):
	keyframes = []
	tracks.clear()
	root = null
	if !path:
		return
		
	var file =File.new()
	file.open(path, File.READ)
	var data = JSON.parse( file.get_as_text() ).result
	file.close()   	
	for d in data:		
		if d.what == "animation":
			root = d			
		elif d.what == "track":
			tracks[d.path_to_parent + "/" + d.name] = d
			tracks[d.path_to_parent + "/" + d.name].keyframes = []
		elif d.what == "keyframe":
			keyframes.push_back(d)
	for k in keyframes:
		tracks[k.path_to_parent].keyframes.push_back(k)

func _set(prop, value):
	for track in get_children():
		if prop == track.name + "/obj":
			trackObjects[track.name] =  value
		if prop == track.name + "/prop":
			trackProperties[track.name] = value
			
func _get(prop):
	for track in get_children():
		if prop == track.name + "/obj":			
			return trackObjects[track.name]
		if prop == track.name + "/prop":											
			return trackProperties[track.name]
	
func _get_property_list():	# overridden function
	var property_list = []	
	for track in get_children(): #tracks:		
		property_list.append({
			"name": track.name +"/obj",
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT,    	
			"type": TYPE_NODE_PATH,
			"hint_string": ""		
		})
		property_list.append({
			"name": track.name +"/prop",
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
