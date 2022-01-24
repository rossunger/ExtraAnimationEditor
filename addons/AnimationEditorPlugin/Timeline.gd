extends ColorRect

func _draw():
	if grid:		
		var a = 0.2
		for i in 20:
			a = 0.2 if i % 5 != 0 else 0.4	
			draw_line(Vector2(i*zoom.x/2,0), Vector2(i*zoom.x/2, rect_size.y), Color(1,1,1,a),3 )
