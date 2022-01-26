tool
extends Control

var dragging = false
var minHeight = 36
var resizeHandle
func _gui_input(event):
	return
	if event is InputEventMouseMotion:
		if getResizeHandle().get_rect().has_point(event.position):
			getResizeHandle().show()
		else:
			getResizeHandle().hide()
			getResizeHandle().hide()
		if dragging:
			rect_min_size.y = max(minHeight, rect_min_size.y + event.relative.y)
	else:
		print(event)
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed():
			dragging = true
			print('begin drag')
		else:
			dragging = false
			print('begin end')

func getResizeHandle():
	if !is_instance_valid(resizeHandle):
		resizeHandle = $resizeHandle
	return resizeHandle


func _on_ToolButton_pressed():
	get_tree().call_group("AnimationEditorPlugin", "showTrackOptions")
