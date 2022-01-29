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

func _gui_input(event):
	return
	if event is InputEventMouseMotion:
		if getResizeHandle().get_rect().has_point(event.position):
			getResizeHandle().show()
		else:
			getResizeHandle().hide()
			getResizeHandle().hide()
		if dragging:
			rect_min_size.y = max(minHeight, rect_min_size.y + event.relative.y)
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			dragging = true			
		else:
			dragging = false
			
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
