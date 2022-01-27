tool
extends Control
var grid = true
var font
func _ready():
	if ! TimelineEditor.is_connected("zoomChanged", self, "zoomChanged"):
		TimelineEditor.connect("zoomChanged", self, "zoomChanged")
		
func zoomChanged():
	update()
	
func _draw():		
	if !font:
		font = get_theme_default_font().duplicate()
		font.size = 22
		
	if grid:		
		var a = 0.02
		for i in 50:
			a = 0.04 if i % 5 != 0 else 0.06
			draw_line(Vector2(i*TimelineEditor.zoom.x/2,0), Vector2(i*TimelineEditor.zoom.x/2, rect_size.y), Color(1,1,1,a),3 )
			if !i % 5:				
				draw_string(font, Vector2(i*TimelineEditor.zoom.x/2 +2,18), str(i), Color(1,1,1,0.3))
