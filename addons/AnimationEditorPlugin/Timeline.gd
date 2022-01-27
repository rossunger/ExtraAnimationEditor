tool
extends Control
var grid = true
var font
var scrolling = false

func _ready():
	if ! TimelineEditor.is_connected("zoomChanged", self, "zoomChanged"):
		TimelineEditor.connect("zoomChanged", self, "zoomChanged")
		
func zoomChanged():
	update()
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			owner.setTime((event.position.x - TimelineEditor.scroll.x) / TimelineEditor.zoom.x )
			owner.applyValues()
		elif event.button_index == 2:
			if event.is_pressed():
				scrolling = true
			else:
				scrolling = false
	if event is InputEventMouseMotion and scrolling:		
		#TimelineEditor.scroll -= event.relative /  TimelineEditor.zoom.x
		TimelineEditor.emit_signal("zoomChanged")
		update()		
		
	
func _draw():
	if !font:
		font = get_theme_default_font().duplicate()
		font.size = 22
		
	if grid:		
		var scroll = Vector2(-TimelineEditor.scroll.x,0)
		var a = 0.02
		for i in 50:
			a = 0.04 if i % 5 != 0 else 0.06
			draw_line(scroll +  Vector2(i*TimelineEditor.zoom.x,0), scroll + Vector2(i*TimelineEditor.zoom.x, rect_size.y), Color(1,1,1,a),3 )
			if !i % 5:				
				draw_string(font, scroll + Vector2(i*TimelineEditor.zoom.x +2,18), str(i), Color(1,1,1,0.3))
