tool
extends Control

#onready var timeValueLabel = $HBoxContainer/TimeValue
#onready var ValueValueLabel = $HBoxContainer/ValueValue

var grid = true		
var zoom = Vector2(100,1)
var offset = Vector2(-12,-12)
var showTimeline = false
var timeline = null
var trackContainer = null
var animation

func setAnimation(obj= animation):
	clearAnimation()	
	
	animation = obj
		
	for track in animation.get_children():		
		if !track is Track:
			print("error: trying to load not a track: ", track.get_path())
			continue			
		getTimeline().add_child(track.duplicate(DUPLICATE_USE_INSTANCING))		
		
		var trackMetaInstance = preload("res://TrackMeta.tscn").instance()		
		getTrackContainer().add_child(trackMetaInstance)	
		trackMetaInstance.get_node("Label").text = track.name		
		
		#for key in track.get_children():
		#	if !key is Keyframe:
		#		continue
		#	var k = preload("res://Keyframe.tscn").instance()
		#	trackInstance.add_child(k)						
	#getTimeline().get_parent().split_offset = 0		
		
	
func clearAnimation():			
	for child in getTimeline().get_children():
		if child is SelectionController:
			continue
		getTimeline().remove_child(child)		
		child.free()			
	for child in getTrackContainer().get_children():
		getTrackContainer().remove_child(child)
		child.free()

func _on_toggleTimelineButton_pressed():
	showTimeline = !showTimeline
	if showTimeline:		
		getTimeline().show()
		rect_min_size.y = 250
	else:
		getTimeline().hide()
		rect_min_size.y = 45
		rect_size.y = 0
		
func getTimeline():	
	if is_instance_valid(timeline):
		return timeline
	else:
		timeline = get_node("VBoxContainer/Animation/Timeline")		
		return timeline
		
func getTrackContainer():
	if is_instance_valid(trackContainer):
		return trackContainer
	else:
		trackContainer = get_node("VBoxContainer/Animation/TrackMeta")		
		return trackContainer


func _on_TrackMeta_gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:
			get_tree().call_group("AnimationEditorPlugin", "addTrack")			


func _on_ChangeContextButton_pressed():
	get_tree().call_group("AnimationEditorPlugin", "changeContext")			


func _on_SaveButton_pressed():
	if !animation:
		return	
	get_tree().call_group("AnimationEditorPlugin", "saveChanges", getTimeline())			
