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
	if !obj:
		return
	if is_instance_valid(animation):
		if obj.name==animation.name:
			return
	clearAnimation()	
	animation = load(obj.filename).instance()
	animation.filename = obj.filename
	$VBoxContainer.add_child(animation)
	trackContainer = get_node("VBoxContainer/" + animation.name + "/TrackMeta")		
	timeline = get_node("VBoxContainer/" + animation.name + "/Timeline")		
	
func clearAnimation():			
	if is_instance_valid(animation):
		animation.queue_free()			

func _on_toggleTimelineButton_pressed():
	showTimeline = !showTimeline
	if showTimeline:		
		for child in get_children():
			if child is ExtraAnimation:				
				child.show()
		rect_min_size.y = 250
	else:
		for child in get_children():
			if child is ExtraAnimation:				
				child.hide()		
		rect_min_size.y = 45
		rect_size.y = 0
			
func _on_TrackMeta_gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:
			get_tree().call_group("AnimationEditorPlugin", "addTrack")			


func _on_ChangeContextButton_pressed():
	get_tree().call_group("AnimationEditorPlugin", "changeContext")			


func _on_SaveButton_pressed():
	if !animation:
		return	
	get_tree().call_group("AnimationEditorPlugin", "saveChanges", animation)			
