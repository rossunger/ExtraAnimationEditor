tool
extends Control
var grid = true
var zoom = Vector2(100,1)
var font
func _draw():		
	if !font:
		font = get_theme_default_font().duplicate()
		font.size = 12
		
	if grid:		
		var a = 0.02
		for i in 50:
			a = 0.03 if i % 5 != 0 else 0.05
			draw_line(Vector2(i*zoom.x/2,0), Vector2(i*zoom.x/2, rect_size.y), Color(1,1,1,a),3 )
			if !i % 5:				
				draw_string(font, Vector2(i*zoom.x/2 +2,10), str(i), Color(1,1,1,0.2))
