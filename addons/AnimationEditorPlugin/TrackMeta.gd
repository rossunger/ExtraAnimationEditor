tool
extends Control

var dragging = false
var minHeight = 36
var resizeHandle
export (String) var track #NODE PATH relative to the animation
var nameLabel
var trackOptionsDialogScene = preload("res://addons/AnimationEditorPlugin/TrackOptions.tscn")
var trackOptionsDialog

func _enter_tree():	
	call_deferred("doInit")
	
func doInit():
	nameLabel = $Label
	name = owner.get_node(track).name
	nameLabel.text = name
	if !is_in_group("Tracks"):
		add_to_group("Tracks")

func updateZoomY():
	rect_min_size.y = 60 * TimelineEditor.zoom.y
	
func validateKeyframeOrder():
	pass

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			dragging = true			
		else:
			dragging = false
			
	return
	if event is InputEventMouseMotion:
		if getResizeHandle().get_rect().has_point(event.position):
			getResizeHandle().show()
		else:
			getResizeHandle().hide()
			getResizeHandle().hide()
		if dragging:
			rect_min_size.y = max(minHeight, rect_min_size.y + event.relative.y)

func getResizeHandle():
	if !is_instance_valid(resizeHandle):
		resizeHandle = $resizeHandle
	return resizeHandle


func _on_ToolButton_pressed():		
	trackOptionsDialog = trackOptionsDialogScene.instance()
	var t = owner.get_node(track)
	if is_instance_valid(t):
		trackOptionsDialog.track = t
		trackOptionsDialog.trackMeta = self
	else:
		print("ERROR: this track meta has no track")
	get_viewport().add_child(trackOptionsDialog)
	trackOptionsDialog.popup()	


func _on_RemoveTrackButton_pressed():
	owner.removeTrack(self)

func updateTrackInfo(theTrack, title, object, property, type):
	#TimelineEditor.addUndo(TimelineEditor.undoTypes.track, theTrack)	
	theTrack.name = title
	theTrack.object = object
	theTrack.property = property
	theTrack.type = type
	track = theTrack.owner.get_path_to(theTrack)
	theTrack.obj = null 	
	_enter_tree()
	
