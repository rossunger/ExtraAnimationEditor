tool
extends Node
class_name SelectionController, "select_icon.png"

# SelectionController singleton. instance a selectBox when you click and drag

signal resizing
signal moving

var parent
var selectBox
export var color = Color.cornflower
var interrupted = false
var timer #used for interrupting the select box
var startPosition

func _enter_tree():	
	#register ourselves as the only selection controller singleton in the EGS (extra gui singleton)	
	if !is_in_group("SelectionController"):
		add_to_group("SelectionController")
	if Engine.editor_hint:
		_ready()
			
func _ready():
	if !is_inside_tree():
		return
	add_to_group("draggable")
	if !has_node("Timer"):
		timer = Timer.new()
		add_child(timer)
		timer.name = "Timer"
	else:
		timer = get_node("Timer")
	if not timer.is_connected("timeout", self, "startSelection"):
		timer.connect("timeout", self, "startSelection")	
	
	
		
func _input(event):			
	if !event is InputEventMouse:
		return	
	if !getParent().get_global_rect().has_point(event.position):		
		return	
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		timer.start(0.01)			
		startPosition = event.position
	
	if event is InputEventMouseButton && event.button_index == 1 && !event.pressed:
		interrupted = false
		
func startSelection():
	timer.stop()
	selectBox = SelectBox.new()
	selectBox.color = color
	selectBox.start = startPosition
	selectBox.end = startPosition
	add_child(selectBox)		
	
func interrupt():	
	if is_instance_valid(timer) and !timer.is_stopped():
		timer.stop()
	elif !interrupted:
		if is_instance_valid(selectBox):			
			selectBox.queue_free()
		interrupted = true

func getParent():
	if !is_instance_valid(parent):
		parent = get_parent()
	return parent
		
func selectBoxFinished(rect):
	if !interrupted:
		if get_tree().get_nodes_in_group("selected").size() > 0:		
			get_tree().call_group("selectable", "deselect")					
	get_tree().call_group("selectable", "drag_select", rect)		
