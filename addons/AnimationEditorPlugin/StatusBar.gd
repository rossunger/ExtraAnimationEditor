tool
extends Control

onready var timeValueLabel = $HBoxContainer/TimeValue
onready var ValueValueLabel = $HBoxContainer/ValueValue

var grid = true		
var zoom = Vector2(100,100)
var offset = Vector2(-12,-12)
var showTimeline = true
onready var timeline = $VBoxContainer/TimelineBackground
func updateTransforms():	
	rect_size.x = get_viewport().size.x- offset.x - 24
	
	#print(get_canvas_transform().get_scale())
	rect_scale = Vector2(1,1)/get_viewport_transform().get_scale() * get_canvas_transform().get_scale()
	
	
	rect_position = (offset + get_viewport_transform().get_origin()) * -rect_scale
	
func _process(delta):
	updateTransforms()

func _on_toggleTimelineButton_pressed():
	showTimeline = !showTimeline
	if showTimeline:
		timeline.show()
	else:
		timeline.hide()
		
