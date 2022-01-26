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
onready var timer = Timer.new() #used for interrupting the select box
var startPosition

func _enter_tree():
	if Engine.editor_hint:
		_ready()
		
func _ready():
	if !is_inside_tree():
		return
	add_to_group("draggable")
	add_child(timer)
	timer.connect("timeout", self, "startSelection")	
	#register ourselves as the only selection controller singleton in the EGS (extra gui singleton)
#	if !is_instance_valid(egs.selectionController):
#		egs.selectionController = self
	#else:				
	#	if egs.selectionController != self:
			#egs.selectionController.queue_free()
	egs.selectionController=self		
		
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
	if !timer.is_stopped():
		timer.stop()
	elif !interrupted:
		if is_instance_valid(selectBox):
			selectBox.getParent().remove_child(selectBox)
			selectBox.queue_free()
		interrupted = true

func getParent():
	if !is_instance_valid(parent):
		parent = get_parent()
	return parent
		
		
		
		
		
		
		
		
