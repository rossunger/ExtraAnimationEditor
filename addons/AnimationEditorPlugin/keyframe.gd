tool
extends ColorRect
class_name Keyframe

signal keyframeChanged
#DATA
export (float) var time = 0.25 setget setTime #in seconds
export var relative = false #absolute or relative
export var value = 0 

export var curve: Curve = Curve.new() 

#PLAYBACK
var startingValue


#EDITING
var oldZoomX
var oldScrollX
var selected = false
var accumulatedDelta = 0
var valid = true
var trackOffset = 0 
func _init():	
	add_to_group("keyframe")
	add_to_group("draggable")
	add_to_group("selectable")	
	
func _ready():		
	#connect("item_rect_changed", self, "rect_changed")
	time = rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x
	if !is_connected("keyframeChanged", TimelineEditor, "keyframeChanged"):
		connect("keyframeChanged", TimelineEditor, "keyframeChanged")
	if !TimelineEditor.is_connected("zoomChanged", self, "setXFromTime"):
		TimelineEditor.connect("zoomChanged", self, "setXFromTime")
	if not is_in_group("Keyframe"):
		add_to_group("Keyframe")
	call_deferred("emit_signal", "keyframeChanged", self)

func rect_changed():
	if self.time == rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x:
		return
	
	if oldZoomX == TimelineEditor.zoom.x and oldScrollX == TimelineEditor.scroll.x:
		setTimeFromX()
		return
	else:
		setXFromTime()
		oldScrollX = TimelineEditor.scroll.x
		oldZoomX = TimelineEditor.zoom.x
		if rect_position.y != 5:
			set_deferred("rect_position",Vector2(rect_position.x, 5))	
			
func setTimeFromX():	
	var newTime =max(0, rect_position.x / TimelineEditor.zoom.x -  TimelineEditor.scroll.x)
	if time != newTime:
		self.time = newTime	
		
func setXFromTime():	
	rect_position.x = time * TimelineEditor.zoom.x - TimelineEditor.scroll.x	
	
func setTime(newTime):
	if newTime == 0:
		time = 0
	elif time == 0:
		return
	elif TimelineEditor.snap > 0:
		newTime = round(newTime / TimelineEditor.snap) * TimelineEditor.snap #todo: fix snapping	
		newTime = max(newTime, 0.1)
	time = newTime 
	setXFromTime()
	emit_signal("keyframeChanged", self)

func reparent(newParent):	
	var currentParent = get_parent()
	if currentParent != newParent:
		currentParent.remove_child(self)
		newParent.add_child(self)
		if not get_parent().validateValueType(value):
			valid = false
		else:
			valid = true

func prepareForDrag():
	trackOffset = TimelineEditor.clickedKey.get_parent().get_index() - get_parent().get_index()	
	TimelineEditor.addUndo(TimelineEditor.undoTypes.keyframe, self)
	#print("preparing for drag undo")	
	
func _gui_input(event):		
	#if Input.is_action_pressed("Click"):		
	if event is InputEventMouseButton and event.is_pressed():					
		TimelineEditor.clickedKey = self
		TimelineEditor.draggingKeys = true		
		for k in get_tree().get_nodes_in_group("selected"):			
			k.prepareForDrag()
		if get_tree().get_nodes_in_group("SelectionController").size()>0:
			get_tree().call_group("SelectionController", "interrupt")		
		if !get_tree().get_nodes_in_group("selected").has(self):
			if Input.is_key_pressed(KEY_SHIFT):
				#ADD TO SELECTION:
				doSelect()
			else:
				get_tree().call_group("selected", "deselect")
				doSelect()
		else:
			if Input.is_key_pressed(KEY_SHIFT):
				deselect()								
		if Input.is_key_pressed(KEY_CONTROL):
			for key in get_tree().get_nodes_in_group("selected"):
				var newkey = key.duplicate()				
				key.get_parent().add_child(newkey)
				key.deselect()
				newkey.time+=0.1
				newkey.setXFromTime()
				newkey.doSelect()
				TimelineEditor.addUndo(TimelineEditor.undoTypes.create, newkey)
		

func _draw():
	if selected:
		var sb = StyleBoxFlat.new()
		sb.border_color = Color.cornflower
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.draw_center = false
		draw_style_box(sb, Rect2(Vector2(0,0), rect_size))
	if not valid:
		var sb = StyleBoxFlat.new()
		sb.border_color = Color.firebrick
		sb.border_width_left = 3
		sb.border_width_right = 3
		sb.border_width_top = 3
		sb.border_width_bottom = 3
		sb.draw_center = false
		draw_style_box(sb, Rect2(Vector2(0,0), rect_size))
		
func drag_select(box: Rect2):	
	if !is_visible_in_tree():
		return
	var r = Rect2(rect_global_position, rect_size)	
	if box.intersects(r) && !r.encloses(box):			
		doSelect()


func doSelect():
	add_to_group("selected")
	selected = true
	TimelineEditor.grab_focus()
	TimelineEditor.selectionChanged(self)
	TimelineEditor.addUndo(TimelineEditor.undoTypes.keyframe, self)	
	#print("adding select undo")		
	update()	

func deselect():		
	selected = false	
	if is_in_group("selected"):
		remove_from_group("selected")
	if get_tree().get_nodes_in_group("selected").size() == 0:
		TimelineEditor.selectionChanged(null)
	update()
	TimelineEditor.addUndo(TimelineEditor.undoTypes.keyframe, self)	
	#print("adding deselect undo")	
	
