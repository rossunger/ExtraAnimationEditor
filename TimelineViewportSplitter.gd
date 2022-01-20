extends VSplitContainer

func _on_TimelineViewportSplitter_dragged(offset):
	var newSize = get_node("ColorRect").rect_size
	#get_node("ColorRect/ViewportContainer").rect_size = newSize
	#get_node("ColorRect/ViewportContainer/PreviewContext").size = newSize
