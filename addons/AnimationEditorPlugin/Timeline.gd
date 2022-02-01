tool
extends Control
var grid = true
var font
var scrolling = false
var tracks setget , getTracks

func getTracks():
	if tracks:
		return tracks
	else:
		if has_node("Tracks"):
			tracks = get_node("Tracks")	
			return tracks
		else:
			print("Tracks doesn't exist yet under timeline")
			return []

func _ready():		
	if ! TimelineEditor.is_connected("zoomChanged", self, "zoomChanged"):
		TimelineEditor.connect("zoomChanged", self, "zoomChanged")
	mouse_filter = Control.MOUSE_FILTER_PASS
	
func zoomChanged():
	update()
	
func _gui_input(event):		
	if event is InputEventMouseButton:				
		if event.doubleclick and event.control:			
			get_tree().call_group("SelectionController", "interrupt")
			get_tree().call_deferred("call_group", "selectable", "doSelect")
			return
		if event.button_index == 1 and event.is_pressed():
			owner.setTime( min(owner.duration, (event.position.x - TimelineEditor.scroll.x) / TimelineEditor.zoom.x ))
			owner.emit_signal("frameChanged")
		elif event.button_index == 2:
			if event.is_pressed():				
				TimelineEditor.scrolling = true
			else:
				TimelineEditor.scrolling = false
		
	if event is InputEventMouseMotion:
		if event.button_mask == 1:
			owner.setTime( max(0, min(owner.duration, (event.position.x - TimelineEditor.scroll.x) / TimelineEditor.zoom.x )))
			owner.emit_signal("frameChanged")
	
func _draw():
	if !font:
		font = get_theme_default_font().duplicate()
		font.size = 22
		
	if grid:		
		var scroll = Vector2(-TimelineEditor.scroll.x,0)
		var a = 0.02
		var lineCount = 20 / TimelineEditor.zoom.x * 100
		var startingLine = TimelineEditor.scroll.x / TimelineEditor.zoom.x
		for j in lineCount:
			var i = j + int(floor(startingLine))
			if lineCount > 150:
				if i % 5 != 0:
					continue
			if lineCount > 250:
				if i % 10 != 0:
					continue
			if lineCount > 500:
				if i % 20 != 0:
					continue
			a = 0.04 if i % 5 != 0 else 0.06
			draw_line(scroll +  Vector2(i*TimelineEditor.zoom.x,0), scroll + Vector2(i*TimelineEditor.zoom.x, rect_size.y), Color(1,1,1,a),3 )
			if !i % 5:				
				draw_string(font, scroll + Vector2(i*TimelineEditor.zoom.x +2,18), str(i), Color(1,1,1,0.3))
